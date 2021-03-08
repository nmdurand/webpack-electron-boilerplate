import path from 'path'
import url from 'url'
import { app, BrowserWindow } from 'electron'

mainWindow = null

# Set up server
# import '../../server/express.coffee'

# Initialize electron-reload
# require('electron-reload') __dirname

app.on 'ready', ->
	mainWindow = new BrowserWindow
		webPreferences:
			nodeIntegration: true

	mainWindow.loadURL(
		url.format
			pathname: path.join __dirname, "./renderer/index.html"
			protocol: "file:"
			slashes: true
	)

	mainWindow.show()

	mainWindow.on 'closed', ->
		win = null
