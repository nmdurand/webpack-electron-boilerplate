import _ from 'underscore'
import Marionette from 'backbone.marionette'

class ConnectionController extends Marionette.Object

	initialize: ->
		console.log 'Initializing Connection...'
		# @socket = require('socket.io-client')()
		# import io from '/socket.io/socket.io.js'
		# import io from 'socket.io-client'
		@socket = io.connect()
		@registerEvents [
			'focusOnLine'
			'displaySong'
			'displayWaitingScreen'
			'transposeChords'
			'resetState'
		]

	emit: (args...)->
		@socket.emit args...

	registerEvents: (events)->
		events.forEach (event)=>
			@socket.on event, (args...)=>
				console.debug 'Client received socket event:',event,args...
				@triggerMethod event, args...

export default ConnectionController
