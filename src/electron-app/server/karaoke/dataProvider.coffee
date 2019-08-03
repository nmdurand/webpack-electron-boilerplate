EventEmitter = require 'events'
fs = require 'fs'
songParser = require '../lib/songParser.coffee'
songProvider = require '../lib/songProvider.coffee'

logger = require('log4js').getLogger 'dataProvider'

isDirectorySync = (path)->
	fs.existsSync(path) and fs.statSync(path).isDirectory()


module.exports =

	class DataProvider extends EventEmitter

		constructor: (@dataPath)->
			super()
			@songList = []
			@allSongs = []
			@songProvider = {}

			unless isDirectorySync @dataPath
				throw new Error "Invalid data path: #{@dataPath}"

			logger.info 'Loading game data.'

			@setSongProvider().then =>
				@emit 'initialized'

		setSongProvider: =>
			@parseDataFolder().then((parsedSongs)=>
				logger.info 'Finished parsing Data folder'
				@songProvider = songProvider parsedSongs
			).catch((err)->
				console.error 'Error parsing songs:',err.stack
				Promise.reject err
			)

		parseDataFolder: =>
			songParser.parseFolder(@dataPath).then((parsedSongs)->
				logger.debug 'Song count found:',parsedSongs.length

				parsedSongs
			).catch (err)->
				console.log 'Error parsing data folder', err

		getSongList: =>
			console.log 'Getting song list'
			@songProvider.list()

		getAllSongData: =>
			console.log 'Getting all songs data.'
			@songProvider.getAllSongs()

		getSong: (id)=>
			console.log 'Getting song:', id
			@songProvider.get id

		updateDataPath: (newDataPath)=>
			@dataPath = newDataPath
			@setSongProvider().then =>
				@emit 'reset'

		getDataPath: =>
			@dataPath
