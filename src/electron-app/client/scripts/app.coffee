import Marionette from 'backbone.marionette'
import Backbone from 'backbone'
import _ from 'underscore'
import MouseTrap from 'mousetrap'

import SongList from './views/screens/songList.coffee'
import Song from './views/screens/song.coffee'
import WaitingView from './views/screens/waiting.coffee'
import Modal from './lib/modal.coffee'
import LoginModalView from './views/setup/loginModal.coffee'
import LogoutModalView from './views/setup/logoutModal.coffee'
import KeychangeModalView from './views/common/keychangeModal.coffee'
import QRCodeModalView from './views/setup/qrcodeModal.coffee'
import LabelEditorModalView from './views/common/labelEditorModal.coffee'
import AppLayoutView from './views/common/appLayout.coffee'

# Override stopCallback method to allow ArrowUp, ArrowDownand Enter key events in song search field
Mousetrap.prototype.stopCallback = (e, element, combo)->
	if ((' ' + element.className + ' ').indexOf(' songSearchfield ') > -1)
		if _.contains ['escape', 'enter', 'arrowdown', 'arrowup'], e.key.toLowerCase()
			return false

	# if the element has the class "mousetrap" then no need to stop
	if ((' ' + element.className + ' ').indexOf(' mousetrap ') > -1)
		return false

	# stop for input, select, and textarea
	return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA' || (element.contentEditable && element.contentEditable == 'true')
######################################################################################

class MyApp extends Marionette.Application
	region: '#mainContainer'
	# songList
	# songData
	# mode
	# connection

	initialize: ->
		@searchQuery = ''
		@songDisplayed = ''
		@lineFocus = 0
		@mode = 'spectator'
		@._region.$el.addClass 'spectator', 'waiting'
		@chordToggle = false
		@transpo = 0
		@currentLabels = []

	openLogModal: =>
		if @mode is 'master'
			@openLogoutModal()
		else
			@openLoginModal()

	openLoginModal: =>
		# Open modal to submit login
		LoginModalView.show
			selectionCallback: (code)=>
				@requestMasterAccess code

	openLogoutModal: =>
		# Open modal to confirm logout
		LogoutModalView.show
			callback: =>
				@appLayout.headerView.updateMenuItemState 'login', false

				@mode = 'spectator'
				@removeModeClasses()
				@._region.$el.addClass 'spectator'

	openKeychangeModal: =>
		KeychangeModalView.show
			key: @currentSongData.key
			transpo: @transpo
			selectionCallback: (transposeValue)=>
				@setSongTransposeValue transposeValue

				if @mode is 'master'
					# Broadcast keychange to all devices
					@setServerTransposeValue transposeValue

	openQRCodeModal: =>
		@connection.emit 'getIPAddress', {}, @showQRCodeModal

	showQRCodeModal: (ipAddress)->
		console.log 'Received ip address, opening qrcode modal', ipAddress
		QRCodeModalView.show
			ipAddress: ipAddress

	openLabelEditorModal: =>
		console.log 'Openeing label editor modal with current labels:', @currentLabels
		LabelEditorModalView.show
			allLabels: @allLabels
			selectedLabels: @currentLabels
			selectionCallback: @setLabels

	setSongTransposeValue: (transposeValue)=>
		console.log 'Defining transposition value:', transposeValue
		@transpo = transposeValue

		@currentView.transposeAndSetChords @transpo

		isTransposed = @transpo isnt 0
		@appLayout.headerView.updateMenuItemState 'keychange', isTransposed

	toggleChords: =>
		if @chordToggle
			@chordToggle = false
		else
			@chordToggle = true

		@appLayout.headerView.updateMenuItemState 'toggleChords', @chordToggle
		if @currentView instanceof Song
			@currentView.toggleChords @chordToggle

	onStart: ->
		@appLayout = new AppLayoutView
		@appLayout.on 'open:log:modal', @openLogModal
		@appLayout.on 'open:keychange:modal', @openKeychangeModal
		@appLayout.on 'open:qrcode:modal', @openQRCodeModal
		@appLayout.on 'open:label:editor:modal', @openLabelEditorModal
		@appLayout.on 'toggle:chords', @toggleChords
		@appLayout.on 'display:song:list', @displaySongList
		@appLayout.on 'remove:label', @removeLabel
		@appLayout.on 'add:label', @addLabel
		@appLayout.on 'display:current:song', @redirectToDefault
		@showView @appLayout

		@router = new Marionette.AppRouter
			controller: @
			appRoutes:
				'': 'redirectToDefault'
				'waiting': 'displayWaitingScreen'
				'waiting/': 'displayWaitingScreen'
				'song/:songId': 'requestSong'
				'songList': 'displaySongList'
				'songList/': 'displaySongList'
				'songList/:searchQuery': 'displaySongList'
				':path': 'redirectToDefault'

		Backbone.history.start()

		@connection.on 'displaySong', @onDisplaySong
		@connection.on 'focusOnLine', @onFocusOnLine
		@connection.on 'displayWaitingScreen', @onDisplayWaitingScreen
		@connection.on 'transposeChords', @onTransposeChords
		@connection.on 'resetState', @onResetState

		@initializeKeyHandlers()

		# Focus back on current line when device is tilted (or browser window resized)
		$(window).on 'resize', =>
			console.log 'resize event !'
			if @currentView instanceof Song
				@currentView.setSongDisplayPadding()
				_.defer @currentView.focusOnCurrentLine()

		@router.onRoute = (args...)->
			Modal.hide() # always close modal if any.

		console.log 'App started'

	navigate: (args)->
		@router.navigate args

	initializeKeyHandlers: ->
		console.group 'Binding key controls.'

		MouseTrap.bind 'right', =>
			if @currentView instanceof Song
				@currentView.requestNextParagraph()
		MouseTrap.bind 'left', =>
			if @currentView instanceof Song
				@currentView.requestPreviousParagraph()
		# Special binding for foot controller
		MouseTrap.bind 'é', =>
			if @currentView instanceof Song
				@currentView.requestNextParagraph()
		MouseTrap.bind '&', =>
			if @currentView instanceof Song
				@currentView.requestPreviousParagraph()

		MouseTrap.bind 'up', =>
			if @isLabelEditorModalOpen()
				# Let modal handle this key
			else if @currentView instanceof Song
				@currentView.requestPreviousLine()
			else if @currentView instanceof SongList
				@currentView.selectPreviousItem()
		MouseTrap.bind 'down', =>
			if @isLabelEditorModalOpen()
				# Let modal handle this key
			else if @currentView instanceof Song
				@currentView.requestNextLine()
			else if @currentView instanceof SongList
				@currentView.selectNextItem()


		$(window).keydown (e)=>
			if e.keyCode is 34 or e.keyCode is 33
				e.preventDefault()

		MouseTrap.bind 'pageup', =>
			if @currentView instanceof Song
				@currentView.requestPreviousLine()
		MouseTrap.bind 'pagedown', =>
			if @currentView instanceof Song
				@currentView.requestNextLine()

		MouseTrap.bind 'enter', =>
			if (@currentView instanceof SongList) and not @isLoginModalOpen()
				@searchQuery = ''
				@currentView.displaySelectedSong()

		MouseTrap.bind 'escape', =>
			unless @isModalOpen()
				@appLayout.headerView.blurSearchfield()

		MouseTrap.bind '@', =>
			# When master, browse songlist without broadcasting it
			if @mode is 'master'
				if @currentView instanceof Song
					@displaySongList()
				else if @currentView instanceof SongList
					@displaySong @currentSongData, @lineFocus, @transpo

		MouseTrap.bind 'c', =>
			# Toggle chords
			if @currentView instanceof Song
				@toggleChords()

		MouseTrap.bind 't', =>
			# Transpose chords
			if @currentView instanceof Song
				if @isKeychangeModalOpen()
					Modal.hide()
				else
					@openKeychangeModal()

		MouseTrap.bind 'q', =>
			# Display connection qr code
			if @isQRCodeModalOpen()
				Modal.hide()
			else
				@openQRCodeModal()

		MouseTrap.bind 'l', =>
			# Login / logout
			unless @isLoginModalOpen() or @isLogoutModalOpen()
				@openLogModal()

		MouseTrap.bind 'f', =>
			# When master, display label filter modal
			if @mode is 'master'
				if @currentView instanceof Song
					@displaySongList()
					@openLabelEditorModal()
				else if @currentView instanceof SongList
					if @isLabelEditorModalOpen()
						Modal.hide()
					else
						@openLabelEditorModal()

		@once 'destroy', @removeKeyHandlers

		console.groupEnd()

	isModalOpen: ->
		$('.modal-open').length

	isLoginModalOpen: ->
		$('.login-modal').length

	isLogoutModalOpen: ->
		$('.logout-modal').length

	isKeychangeModalOpen: ->
		$('.keychange-modal').length

	isQRCodeModalOpen: ->
		$('.qrcode-modal').length

	isLabelEditorModalOpen: ->
		$('.labelEditor-modal').length

	removeKeyHandlers: ->
		MouseTrap.reset()

	selectSpectatorMode: =>
		console.log 'Selecting Spectator Mode'
		@mode = 'spectator'
		@removeModeClasses()
		@._region.$el.addClass @mode
		@connection.emit 'selectMode', 'spectator', (songData, lineIndex)=>
			if @mode is 'spectator'
				console.group 'Current mode set to Spectator'
				if songData
					console.log 'Current song retrieved, displaying...'
					@displaySong songData
					@currentView.focusOnLine lineIndex
				else
					console.log 'No current song, displaying waiting screen'
					@displayWaitingScreen()
				console.groupEnd()

	requestMasterAccess: (code)=>
		console.group 'Requesting authorization to access Master mode'
		@connection.emit 'requestMasterAccess', code, (autho)=>
			if autho
				@mode = 'master'
				@removeModeClasses()
				@._region.$el.addClass 'master'
				console.log 'Access authorized: current mode set to Master'
				@appLayout.headerView.updateMenuItemState 'login', true
				@displaySongList()
			else
				console.log 'Access to Master mode denied'
		console.groupEnd()

	removeModeClasses: =>
		@._region.$el.removeClass 'master'
		@._region.$el.removeClass 'spectator'

	actualizeScreenClass: (screenClass)=>
		@._region.$el.removeClass 'song'
		@._region.$el.removeClass 'songList'
		@._region.$el.removeClass 'waiting'
		@._region.$el.addClass screenClass


	redirectToDefault: =>
		console.log 'Redirecting to default route.'
		@connection.emit 'requestCurrentSong', (songData, lineIndex, transpo)=>
			if songData
				console.log 'Current song retrieved, displaying...'
				@displaySong songData
				@currentView.focusOnLine lineIndex
				@setSongTransposeValue transpo
			else
				console.log 'No current song, displaying waiting screen'
				@displayWaitingScreen()

	displayWaitingScreen: =>
		waiting = new WaitingView
		@currentView = waiting
		waiting.on 'displaySong', (songId)=>
			@displaySong songId
		@navigate "waiting/"
		@appLayout.showMainView waiting
		@appLayout.setHeaderTitle 'Happi-Karaoke'
		@actualizeScreenClass 'waiting'

	displaySongList: =>
		console.group 'Requesting song list data...'
		@searchQuery = ''
		@connection.emit 'getSongList', '', (songListData)=>
			console.log 'Song List data received...'
			@registerAllLabels songListData
			songList = new SongList
				collection: new Backbone.Collection songListData
				currentLabels: @currentLabels
				viewComparator: 'artist'
			@currentView = songList
			songList.on 'request:song', @requestSong
			@appLayout.showMainView songList
			@appLayout.setHeaderTitle ''
			@appLayout.headerView.focusOnSearchfield()
			@actualizeScreenClass 'songList'
		console.groupEnd()

	registerAllLabels: (songListData)=>
		@allLabels = []
		for song in songListData
			if song.labels?
				@allLabels = @allLabels.concat song.labels
				@allLabels = _.uniq @allLabels

	onAccessMasterController: (accessGranted)=>
		console.log '>>>>>> Access Master Controller event received, value:', accessGranted
		if accessGranted
			@triggerMethod 'select:mode', 'master'

	onDisplaySong: (songData)=>
		console.log '>> displaySong message received by the client App'
		@displaySong songData

	onFocusOnLine: (lineIndex)=>
		console.log '>> focusOnLine message received by the client App'
		if lineIndex >= 0
			@lineFocus = lineIndex
			@currentView.focusOnLine lineIndex

	onTransposeChords: (transposeValue)=>
		console.log '>> transposeChords message received by the client App'
		@setSongTransposeValue transposeValue

	onDisplayWaitingScreen: =>
		console.log '>> displayWaitingScreen message received by the client App'
		@displayWaitingScreen()

	onResetState: =>
		console.log '>> resetState message received by the client App'
		@resetState()

	resetState: =>
		@resetDisplayValues()
		@currentSongData = {}
		@appLayout.setStatusBarDetails {}
		@setLabels []

		@searchQuery = ''
		@appLayout.headerView.setSearchField ''

		if @mode is 'master'
			@displaySongList()
		else
			@displayWaitingScreen()

	requestSong: (songId)=>
		if @mode is 'master'
			console.log 'Sending song data request, ID:', songId
			@connection.emit 'broadcastSong', songId

	addLabel: (label)=>
		console.log 'Adding label:', label
		unless _.contains @currentLabels, label
			@currentLabels.push label
		@setFilterLabels()

	removeLabel: (label)=>
		console.log 'Removing label:', label
		@currentLabels = _.reject @currentLabels, (filterLabel)-> filterLabel is label
		@setFilterLabels()

	setLabels: (labels)=>
		@currentLabels = labels
		@setFilterLabels()

	setFilterLabels: =>
		@appLayout.setFilterLabels @currentLabels

	resetDisplayValues: =>
		@transpo = 0
		@appLayout.headerView.updateMenuItemState 'keychange', false
		@lineFocus = 0

	displaySong: (songData, lineFocus = 0, transpo = 0)=>
		@currentSongData = songData
		if songData.id
			@navigate "song/#{songData.id}"
			console.log 'Requested Song:', songData

			@lineFocus = lineFocus
			@transpo = transpo
			isTransposed = @transpo isnt 0
			@appLayout.headerView.updateMenuItemState 'keychange', isTransposed

			song = new Song
				songData: songData
				chordToggle: @chordToggle
				transpo: transpo
				lineFocus: lineFocus
			@currentView = song
			song.on 'broadcast:line:index', (index)=>
				@lineFocus = index
				if @mode is 'master'
					@setServerLineFocus index

			@appLayout.showMainView song
			@appLayout.setHeaderTitle songData.title
			@actualizeScreenClass 'song'

			@appLayout.setStatusBarDetails @currentSongData

		else
			console.log 'Song data:', songData
			@displaySongList()
			throw new Error 'Invalid song ID requested.'


	recordChordSwitchValue: (value)=>
		@chordToggle = value

	setServerLineFocus: (index)=>
		console.log 'Setting server line focus value.'
		@connection.emit 'setLineFocus', index

	setServerTransposeValue: (transposeValue)=>
		console.log 'Setting server transposition value.'
		@connection.emit 'setTransposeValue', transposeValue

export default MyApp
