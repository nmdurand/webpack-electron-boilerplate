
import Marionette from 'backbone.marionette'
import HeaderView from './header.coffee'
import SongList from '../screens/songList.coffee'
import StatusBar from './statusBar.coffee'

class AppLayoutView extends Marionette.View
	className: 'app-layout'
	template: require '../../templates/common/appLayout.hbs'

	regions:
		headerRegion: '#titleBar'
		statusRegion: '#statusBar'
		mainRegion: '#main-content'

	initialize: ->
		console.log 'Initializing AppLayout View:',@options

	onRender: ->
		@headerView = new HeaderView
		@headerView.on 'open:log:modal', @openLogModal
		@headerView.on 'open:keychange:modal', @openKeychangeModal
		@headerView.on 'open:qrcode:modal', @openQRCodeModal
		@headerView.on 'edit:labels', @openLabelEditorModal
		@headerView.on 'toggle:chords', @toggleChords
		@headerView.on 'filter:list', @filterList
		@headerView.on 'remove:label', @removeLabel
		@headerView.on 'add:label', @addLabel
		@headerView.on 'display:song:list', @displaySongList
		@getRegion('headerRegion').show @headerView

		@statusBar = new StatusBar
		@statusBar.on 'display:current:song', @displayCurrentSong
		@getRegion('statusRegion').show @statusBar

	openLogModal: =>
		# console.log 'Opening login / logout modal.'
		@trigger 'open:log:modal'

	openKeychangeModal: =>
		# console.log 'Opening keychange modal.'
		@trigger 'open:keychange:modal'

	openQRCodeModal: =>
		# console.log 'Opening qrcode modal.'
		@trigger 'open:qrcode:modal'

	openLabelEditorModal: =>
		# console.log 'Opening qrcode modal.'
		@trigger 'open:label:editor:modal'

	toggleChords: =>
		# console.log 'Toggling chords.'
		@trigger 'toggle:chords'

	displayCurrentSong: =>
		# console.log 'Displaying current Song.'
		@trigger 'display:current:song'

	filterList: (query)=>
		if @currentView instanceof SongList
			@currentView.filterList query

	removeLabel: (label)=>
		@trigger 'remove:label', label

	addLabel: (label)=>
		@trigger 'add:label', label

	displaySongList: =>
		# console.log 'Displaying the song list.'
		@trigger 'display:song:list'

	setStatusBarDetails: (songDetails)=>
		console.log 'Setting status bar details', songDetails
		@statusBar.title = songDetails?.title ? ''
		@statusBar.artist = songDetails?.artist ? ''
		@statusBar.render()

	setHeaderTitle: (title)=>
		@headerView.setTitle title

	updateMenuItemState: (itemId, state)->
		@headerView.updateMenuItemState itemId, state

	showMainView: (view)=>
		@currentView = view
		@getRegion('mainRegion').show view
		if @currentView instanceof SongList
			@currentView.on 'add:label', @addLabel

	setFilterLabels: (labels)=>
		@headerView.setFilterLabels labels
		if @currentView instanceof SongList
			@currentView.setFilterLabels labels

export default AppLayoutView
