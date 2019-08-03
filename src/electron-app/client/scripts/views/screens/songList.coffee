import Marionette from 'backbone.marionette'
import _ from 'underscore'
import StringUtils from '../../utils/string.coffee'

class SongDetails extends Marionette.View
	tagName: 'li'
	className: 'songDetails list-group-item'
	template: require '../../templates/screens/songDetails.hbs'
	triggers:
		'click': 'request:song'

	events:
		'click .label': 'handleClickOnLabel'

	initialize: ->
		if @model.get 'fileError'
			console.log 'Detected a file error in', @model.get 'file'
			@.$el.addClass 'error'

	attributes: ->
		songid: @getId()

	getId: ->
		@model.get 'id'

	getLabels: ->
		@model.get 'labels'

	handleClickOnLabel: (e)->
		e.stopPropagation()
		console.log 'click on label.'
		@trigger 'add:label', e.target.dataset.label


class EmptyView extends Marionette.View
	tagName: 'div'
	className: 'no-results'
	template: require '../../templates/screens/songListEmptyView.hbs'

class SongList extends Marionette.NextCollectionView
	className: 'songListScreen'
	template: require '../../templates/screens/songList.hbs'
	childView: SongDetails
	childViewContainer: '#songList'
	emptyView: EmptyView

	childViewEvents:
		'click': 'handleChildViewClick'

	initialize: ->
		console.log 'Initializing songList view with options:', @options
		{currentLabels} = @options
		@currentLabels = if currentLabels? then currentLabels else []
		@selectedId = ""

		@filterList()

	templateContext: ->
		searchQuery: @options.searchQuery

	onChildviewRequestSong: (songDetailsView)->
		@trigger 'request:song',songDetailsView.getId()

	onChildviewAddLabel: (label)->
		@trigger 'add:label', label

	filterList: (query)=>
		console.log 'SongList View filtering list with query:', query, 'and labels:', @currentLabels
		@setFilter (child,index,collection)->
			result = true

			# Filter labels
			unless _.isEmpty @currentLabels
				@currentLabels.forEach (label)->
					unless _.contains child.getLabels(), label
						result = false

			# Then filter query
			unless _.isEmpty query
				result = result and ((child.model.get('searchArtist').includes query) or (child.model.get('searchTitle').includes query))

			result

	setFilterLabels: (labels)=>
		@currentLabels = labels
		@filterList()

	getSelectedItem: =>
		if @$('.songDetails.selected').length
			selectedItem = @$('.songDetails.selected')
		else
			false

	selectNextItem: =>
		if selectedItem = @getSelectedItem()
			# If an item is already selected
			nextItem = selectedItem.next('.songDetails:not(.error)')
			selectedItem.removeClass 'selected'
			nextItem.addClass 'selected'
			@selectedId = nextItem.attr 'songid'

			if _.isEmpty @selectedId
				console.log 'No selected song'
			else
				console.log 'Selected song id:', @selectedId
		else if @$('.songDetails:not(.error)').length > 0
			# Else select the first in the list
			nextItem = @$('.songDetails:not(.error)').first()
			nextItem.addClass 'selected'
			@selectedId = nextItem.attr 'songid'

			if _.isEmpty @selectedId
				console.log 'No selected song'
			else
				console.log 'Selected song id:', @selectedId
		else
			console.log 'No selectable item in the list!'


	selectPreviousItem: =>
		if selectedItem = @getSelectedItem()
			# If an item is already selected
			prevItem = selectedItem.prev('.songDetails:not(.error)')
			selectedItem.removeClass 'selected'
			prevItem.addClass 'selected'
			@selectedId = prevItem.attr 'songid'

			if _.isEmpty @selectedId
				console.log 'No selected song'
			else
				console.log 'Selected song id:', @selectedId
		else if @$('.songDetails:not(.error)').length > 0
			# Else select the last in the list
			prevItem = @$('.songDetails:not(.error)').last()
			prevItem.addClass 'selected'
			@selectedId = prevItem.attr 'songid'

			if _.isEmpty @selectedId
				console.log 'No selected song'
			else
				console.log 'Selected song id:', @selectedId
		else
			console.log 'No selectable item in the list!'

	displaySelectedSong: =>
		unless _.isEmpty @selectedId
			@triggerMethod 'request:song', @selectedId
		else
			console.log 'No selected song'


export default SongList
