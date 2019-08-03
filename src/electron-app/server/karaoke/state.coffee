_ = require 'lodash'
events = require 'events'
debug = require('debug')('karaoke:state')

logger = require('log4js').getLogger 'state'

module.exports =

	class State extends events.EventEmitter

		constructor: ->
			super()
			logger.info "Creating karaoke server state."

			@resetState()

		resetState: ->
			logger.info 'Resetting karaoke server state.'
			@setState
				songId: ''
				lineFocus: 0
				transpo: 0

		getState: ->
			songId: @songId
			lineFocus: @lineFocus
			transpo: @transpo

		setState: (state, silent)->
			unless state?
				logger.debug 'Ignoring null or empty state.'
				return

			@setCurrentSongId(state.songId, true) if state?.songId?
			@setCurrentLineFocus(state.linefocus, true) if state?.linefocus?
			@setCurrentTranspo(state.transpo, true) if state?.transpo?

			unless silent
				@emit 'karaokeState:change'

		getCurrentSongId: ->
			@songId

		getCurrentLineFocus: ->
			@lineFocus

		getCurrentTranspo: ->
			@transpo

		setCurrentSongId: (songId, silent)->
			# console.log '> Setting new song Id'
			@songId = songId
			unless silent
				@emit 'songId:change'

		setCurrentLineFocus: (lineFocus, silent)->
			# console.log '> Setting new lineFocus value'
			@lineFocus = lineFocus
			unless silent
				@emit 'lineFocus:change'

		setCurrentTranspo: (transpo, silent)->
			# console.log '> Setting new transpo value'
			@transpo = transpo
			unless silent
				@emit 'transpo:change'
