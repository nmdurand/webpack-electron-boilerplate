import _ from 'underscore'
import Marionette from 'backbone.marionette'
import io from 'socket.io-client'

class ConnectionController extends Marionette.Object

	initialize: ->
		console.log 'Initializing Connection...'
		@socket = io()
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
