import express from 'express'
import http from 'http'
import path from 'path'
import EventEmitter from 'events'
import _ from 'lodash'
import fs from 'fs'
import json2csv from 'json2csv'
import DataProvider from './karaoke/dataProvider.coffee'
import KaraokeState from './karaoke/state.coffee'
import Connection from './karaoke/connection.coffee'

import mkdirp from 'mkdirp'
import log4js from 'log4js'

import songParser from './lib/songParser.coffee'
import ipProvider from './lib/ipProvider.coffee'

createKaraokeContext = (dataPath)->
	logger = log4js.getLogger 'gameContext'

	context = new EventEmitter

	context.state = new KaraokeState
	context.dataProvider = new DataProvider dataPath

	context


ExpressServer = (appRoot, cwd, config, configPath)->

	serverModule = {}
	context = null

	console.log 'Using working dir:',cwd
	process.chdir cwd

	mkdirp.sync 'logs'

	LOG4JS_CONFIG = require './config/log4js.json'
	#log4js.setGlobalLogLevel 'DEBUG'
	log4js.configure LOG4JS_CONFIG

	processContentsPath = (contentsPath)->
		if not contentsPath.match /^\//
			console.log 'Processing relative path:',config.contentFolderPath
			contentsPath = path.join cwd, config.contentFolderPath
		contentsPath

	contentsPath = processContentsPath config.contentFolderPath

	console.log 'Using contentsPath:',contentsPath

	updateDataPath = (newPath, callback)->
		console.log 'Updating data path to:',newPath
		newConfig = _.cloneDeep config
		newConfig.contentFolderPath = newPath
		fs.writeFile configPath,JSON.stringify(newConfig,null,"\t"),(err)->
			if err
				console.error 'Error updating config file:',err.code
			else
				console.log 'Config file updated.'

			callback err if callback

		context.dataProvider.updateDataPath newPath

	exportCSV = (destPath, callback)->
		songList = context.dataProvider.getSongList()

		# Exclude songs with fileErrors ; sort by artist and title
		songList = _.reject songList, (song)-> song.fileError
		songList = _.sortBy songList, ['artist', 'title']

		if not fs.existsSync destPath
			mkdirp.sync destPath

		# Use the name of the data source folder to build the csv export file name
		dataPath = context.dataProvider.getDataPath()
		destFileName = path.parse(dataPath).name

		csvExportFilePath = path.format
			dir: destPath
			name: destFileName
			ext: '.csv'

		{Parser} = json2csv
		fields = [
			label: 'ARTIST'
			value: 'artist'
		,
			label: 'TITLE'
			value: 'title'
		,
			label: 'KEY'
			value: 'key'
		]
		parser = new Parser {fields}
		csvData = parser.parse songList


		fs.writeFile csvExportFilePath, csvData, (err)->
			if err
				console.error 'Error  exporting csv file:',err.code

			callback(err,csvExportFilePath) if callback


	Promise.resolve().then ->
		app = express()
		server = http.createServer app

		logger = log4js.getLogger 'express'
		# console.log 'Folders...', process.env.HOME


		context = createKaraokeContext contentsPath
		context.dataProvider.on 'initialized', ->
			logger.info 'Context initialized, setting up socket handling.'
			context.connection = new Connection server,context

		context.dataProvider.on 'reset', ->
			logger.info 'Dataprovider reset, broadcasting reset songlist message.'
			context.state.resetState()
			context.connection.emit 'resetState'

		# if 'production' is app.get('env')
		# 	debug 'Using express production mode.'
		# 	app.use express.static('../public')
		# else
		# 	debug 'Using express dev mode.'
		app.use express.static(path.join(__dirname,'public'))

		server.on 'error', (err)->
			console.log "Server Error:", err
			if err.errno is 'EADDRINUSE'
				serverModule.errors = "Port #{config.port} already in use."
				context.emit 'serverError', "Port #{config.port} already in use."
			else
				serverModule.errors = "Server stopped, error code #{err.errno}."
				context.emit 'serverError', "Server stopped, error code #{err.errno}."

			server.close()

		server.listen config.port, ->
			console.log "App listening on port #{config.port}!"


	serverModule =
		updateDataPath: updateDataPath
		context: context
		exportCSV: exportCSV


export default ExpressServer
