import _ from 'lodash'

import socket from 'socket.io'
import ipProvider from '../lib/ipProvider.coffee'

import log4js from 'log4js'
logger = log4js.getLogger 'socket'
import internalConfig from '../config/main.coffee'


class Connection

	constructor: (app, context)->
		logger.info 'Initializing socket.io...'
		@io = socket.listen app

		{@dataProvider, @state} = context

		currentSongData = null
		currentLineFocus = 0

		@state.on 'songId:change', =>
			songData = @dataProvider.getSong @state.getCurrentSongId()
			@io.emit 'displaySong', songData

		@state.on 'lineFocus:change', =>
			lineFocus = @state.getCurrentLineFocus()
			@io.emit 'focusOnLine', lineFocus

		@state.on 'transpo:change', =>
			transpo = @state.getCurrentTranspo()
			@io.emit 'transposeChords', transpo

		@io.sockets.on 'connection', (clientSocket)=>
			console.log 'Client connected the server:',clientSocket.request.connection._peername
			clientSocket.join 'spectator'

			clientSocket.on 'selectMode', (message, callback)->
				console.log 'selectMode message received:', message
				if message is 'spectator'
					clientSocket.leave 'master'
					clientSocket.join 'spectator'
					if currentSongData isnt null
						callback currentSongData, currentLineFocus
					else callback()

			clientSocket.on 'requestMasterAccess', (code, callback)->
				console.log 'requestMasterAccess message received with code:', code
				if parseInt(code) is internalConfig.masterPin
					console.log 'Master Access granted.'
					clientSocket.leave 'spectator'
					clientSocket.join 'master'
					callback true
				else
					console.log 'Master Access denied.'
					callback false

			clientSocket.on 'getIPAddress', (message,callback)->
				callback ipProvider.getIp()

			clientSocket.on 'getSong', (message,callback)=>
				console.log 'getSong message received:',message
				result = @dataProvider.getSong(message)
				if result
					callback result
				else
					callback null

			clientSocket.on 'broadcastSong', (songId)=>
				console.log 'broadcast Song message received:',songId
				songData = @dataProvider.getSong(songId)
				if songData?
					@state.setCurrentSongId songId

			clientSocket.on 'requestCurrentSong', (callback)=>
				console.log 'requestCurrentSong message received.', @state
				if @state.getCurrentSongId()?
					songData = @dataProvider.getSong @state.getCurrentSongId()
					if songData?
						lineFocus = @state.getCurrentLineFocus()
						transpo = @state.getCurrentTranspo()
						callback songData, lineFocus, transpo
					else callback()

				else callback()

			clientSocket.on 'getSongList', (message,callback)=>
				console.log 'getSongList message received.'
				songList = @dataProvider.getSongList()
				if songList?
					callback songList
				else
					callback null

			clientSocket.on 'setLineFocus', (lineFocus)=>
				@state.setCurrentLineFocus lineFocus

			clientSocket.on 'setTransposeValue', (transpo)=>
				console.log 'setTransposeValue message received, transpo:', transpo
				@state.setCurrentTranspo transpo

			clientSocket.on 'broadcastWaitingScreen', =>
				console.log 'broadcastWaitingScreen message received'
				@state.resetState()
				clientSocket.broadcast.to('spectator').emit 'displayWaitingScreen'


		logger.info 'Socket.io routes initialized.'


	emit: (args...)=>
		@io.sockets.emit args...

export default Connection
