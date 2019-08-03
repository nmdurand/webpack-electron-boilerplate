import path from 'path'
import url from 'url'
import fs from 'fs'
import network from 'network'
import _ from 'lodash'
import { app, BrowserWindow, dialog, ipcMain } from 'electron'

win = null

ADDRESS_REFRESH_DELAY = 3*1000 # ms


# Set up server
# require './server/express.coffee'

# Initialize electron-reload
require('electron-reload') __dirname


userConfigFolder = path.join app.getPath('documents'), 'HappiKaraoke'
userConfigFile = path.join userConfigFolder, 'config.json'

if not fs.existsSync userConfigFile
	console.log 'User config file not found, creating with default values.'
	mkdirp = require 'mkdirp'
	defaultConfig = require './config/default.coffee'

	mkdirp.sync userConfigFolder
	fs.writeFileSync userConfigFile, JSON.stringify(defaultConfig, null, '\t')

userConfig = JSON.parse fs.readFileSync(userConfigFile)

console.log 'Running electron with config:', userConfig

# serverPath = path.join __dirname, './server/express'
# console.log path.resolve serverPath
serverModule = require('./server/express.coffee')(app.getAppPath(), userConfigFolder, userConfig, userConfigFile)

# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the JavaScript object is garbage collected.
mainWindow = null

# Quit when all windows are closed.
app.on 'window-all-closed', ->
	# On OS X it is common for applications and their menu bar
	# to stay active until the user quits explicitly with Cmd + Q
	if process.platform isnt 'darwin'
		app.quit()

# This method will be called when Electron has finished
# initialization and is ready to create browser windows.
app.on 'ready', ->

	ipcMain.on 'request:server:config', (event)->
		console.log 'Server config requested.'
		packageInfo = require '../../package.json'

		event.returnValue =
			error: serverModule.errors
			config: _.assign {},userConfig,
				applicationName: packageInfo.displayName
				applicationVersion: packageInfo.version
				configPath: userConfigFile

	ipcMain.on 'request:window:size', (event,args)->
		console.log 'Resize requested:',args
		mainWindow.setSize args.width,args.height

	ipcMain.on 'request:datapath:selection', (event)->
		console.log 'Datapath selection requested.'
		options =
			properties: ['openDirectory']

		dialog.showOpenDialog mainWindow,options,(filenames)->
			unless _.isEmpty filenames
				[selectedFile] = filenames
				console.log 'File selected:',selectedFile
				serverModule.updateDataPath selectedFile,(err)->
					event.sender.send 'result:datapath:selection',
						error: err
						selectedPath: selectedFile

	ipcMain.on 'request:csv:export', (event)->
		destPath = path.join userConfigFolder, 'csv'

		serverModule.exportCSV destPath, (err, csvExportPath)->
			event.sender.send 'result:csv:export',
				error: err
				csvExportPath: csvExportPath
			app.dock.bounce()

	# Create the browser window.
	mainWindow = new BrowserWindow
		useContentSize: true
		resizable: true
		fullscreenable: false
		width: 768
		height: 700
		minWidth: 768
		webPreferences:
			nodeIntegration: true

	mainWindow.loadURL(
		url.format
			pathname: path.join __dirname, "./renderer/index.html"
			protocol: "file:"
			slashes: true
	)

	mainWindow.webContents.openDevTools()


	# Emitted when the window is closed.
	mainWindow.on 'closed', ->
		# Dereference the window object, usually you would store windows
		# in an array if your app supports multi windows, this is the time
		# when you should delete the corresponding element.
		mainWindow = null
		process.exit(0)

	# serverModule context does not exist if content has errors.
	serverModule.context?.on 'serverError', (error)->
		mainWindow.webContents.send 'error',error

# IP addressList

	storedAddresses = []

	ipcMain.on 'request:ipAddresses', ->
		getIpAddressList (err, addresses)->
			storedAddresses = addresses
			mainWindow.webContents.send 'ipAddresses:list', err, addresses

	getIpAddressList = (callback)->
		network.get_interfaces_list (err, list)->
			if err
				console.warn "Could not get address list", err
				callback err
			else
				addresses = for item in list when item.ip_address
					item.ip_address

				callback null, addresses

	checkForAddressChange = ->
		getIpAddressList (err, newAddresses)->
			if err
				clearInterval ipAddressInterval
			else if not _(storedAddresses).xor(newAddresses).isEmpty()
				console.log 'Addresses have changed!'
				storedAddresses = newAddresses
				mainWindow.webContents.send 'ipAddresses:change', newAddresses

	ipAddressInterval = setInterval checkForAddressChange, ADDRESS_REFRESH_DELAY
