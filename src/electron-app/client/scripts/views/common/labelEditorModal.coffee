import Marionette from 'backbone.marionette'
import Modal from '../../lib/modal.coffee'
import _ from 'lodash'
import $ from 'jquery'
import StringUtils from '../../utils/string.coffee'
import MouseTrap from 'mousetrap'

SELECTED_CLASS = 'selected'
QUERIED_CLASS = 'queried'

class LabelItemView extends Marionette.View
	className: 'labelItem'
	template: require '../../templates/common/labelEditor/item.hbs'

	events:
		'click': 'handleClickOnLabelItem'

	onAttach: ->
		if @model.get 'selected'
			@$el.addClass 'selected'

	handleClickOnLabelItem: =>
		@$el.toggleClass SELECTED_CLASS
		@model.set 'selected', @$el.hasClass('selected')


class EmptyView extends Marionette.View
	tagName: 'div'
	className: 'no-results'
	template: require '../../templates/common/labelEditor/emptyView.hbs'

class LabelEditorModalView extends Marionette.CompositeView
	className: 'labelEditor-modal modal-dialog'
	template: require '../../templates/common/labelEditorModal.hbs'
	childView: LabelItemView
	childViewContainer: '#labelSelector'
	emptyView: EmptyView

	ui:
		submitButton: '.submitButton'
		modalBackdrop: '.labelEditor-modal'

		labelSearchfield: '#label-searchfield'
		searchFieldInput: '.labelSearchfield'
		searchfieldEmptyButton: '#label-searchfield.query-present .input-group-addon'
		searchfieldSearchButton: '#label-searchfield:not(.query-present) .input-group-addon'

	events:
		'keyup #label-searchfield': 'handleTextInputEvent'
		'click @ui.searchfieldEmptyButton': 'removeQuery'
		'click @ui.searchfieldSearchButton': 'handleSearchClick'
		'click @ui.submitButton': 'submitLabelSelection'
		'click @ui.modalBackdrop': 'closeModal'

	initialize: ->
		console.log 'Initializing labelEditor modal view.', @options
		{@allLabels, @selectedLabels} = @options

		labels = @allLabels.map (label)=>
			name: label
			searchName: StringUtils.normalize label
			selected: @selectedLabels.includes label

		@collection = new Backbone.Collection labels
		@collection.comparator = 'name'
		@collection.sort()

		@initializeKeyHandlers()

	onRender: =>
		@focusOnSearchfield()

	@show: (options)->
		modalView = new LabelEditorModalView options

		modalView.on 'submit', options.selectionCallback

		console.log 'Showing modal view'
		Modal.show modalView

	closeModal: =>
		Modal.hide @

	initializeKeyHandlers: ->
		console.group 'Binding key controls.'
		MouseTrap.bind 'up', => @selectPreviousLabel()
		MouseTrap.bind 'down', => @selectNextLabel()
		MouseTrap.bind 'space', => @toggleQueriedLabel()


	focusOnSearchfield: =>
		console.log 'Focusing on search field'
		setTimeout (=>
			@ui.searchFieldInput.focus()
			), 0

	blurSearchfield: =>
		@ui.searchfieldInput.blur()

	getSelection: =>
		selection = []
		@children.each (child)->
			if child.model.get 'selected'
				selection.push child.model.get 'name'
		selection

	submitLabelSelection: =>
		selection = @getSelection()
		@trigger 'submit', selection
		@closeModal()

	handleTextInputEvent: (event)=>
		query = StringUtils.normalize @ui.searchFieldInput.val()
		if event.key is 'Enter'
			# Enter key validates label selection
			@submitLabelSelection()
		else if event.key is 'ArrowDown'
			@selectNextLabel()
		else if event.key is 'ArrowUp'
			@selectPreviousLabel()
		else if event.key is ' '
			# Space key toggles queried label
			@toggleQueriedLabel()
			@removeLastCharFromQuery()
		else
			@updateSearchFieldIcons()
			@filterLabels query
			@updateLabelsState query

	updateSearchFieldIcons: ->
		if _.isEmpty @ui.searchFieldInput.val()
			@ui.labelSearchfield.removeClass 'query-present'
		else
			@ui.labelSearchfield.addClass 'query-present'

	removeLastCharFromQuery: ->
		query = @ui.searchFieldInput.val()
		truncQuery = query.slice(0, -1)
		@ui.searchFieldInput.val truncQuery

	removeQuery: ->
		@ui.searchFieldInput.val ''
		@updateSearchFieldIcons()
		@filterLabels ''
		@updateLabelsState ''

	toggleQueriedLabel: =>
		@children.each (child)->
			if child.$el.hasClass QUERIED_CLASS
				if child.$el.hasClass SELECTED_CLASS
					child.model.set 'selected', false
					child.$el.removeClass SELECTED_CLASS
				else
					child.model.set 'selected', true
					child.$el.addClass SELECTED_CLASS

	handleSearchClick: =>
		@focusOnSearchfield()

	updateLabelsState: (query)=>
		@children.each (child)->
			if child.model.get('searchName') is query
				child.$el.addClass 'queried'
			else
				child.$el.removeClass 'queried'

	validateQuery: (query)=>
		@children.each (child)->
			if child.model.get('searchName') is query
				if child.model.get 'selected'
					child.model.set 'selected', false
					child.$el.removeClass SELECTED_CLASS
				else
					child.model.set 'selected', true
					child.$el.addClass SELECTED_CLASS

	filterLabels: (query)=>
		console.log 'labelEditorModal View filtering list with query:', query
		@setFilter (child,index,collection)->
			unless _.isEmpty query
				result = child.get('searchName').includes query
			else
				result = true

			result
		@collection.sort()

	getQueriedLabel: =>
		if $('.labelItem.queried').length
			selectedLabel = $('.labelItem.queried')
		else
			false

	selectNextLabel: =>
		if queriedLabel = @getQueriedLabel()
			# If an item is already selected
			nextLabel = queriedLabel.next('.labelItem')
			queriedLabel.removeClass QUERIED_CLASS
			nextLabel.addClass QUERIED_CLASS

		else if $('.labelItem').length > 0
			# Else select the first in the list
			nextLabel = $('.labelItem').first()
			nextLabel.addClass QUERIED_CLASS

		else
			console.log 'No selectable label in the list!'


	selectPreviousLabel: =>
		if queriedLabel = @getQueriedLabel()
			# If an item is already selected
			prevLabel = queriedLabel.prev('.labelItem')
			queriedLabel.removeClass QUERIED_CLASS
			prevLabel.addClass QUERIED_CLASS

		else if $('.labelItem').length > 0
			# Else select the last in the list
			prevLabel = $('.labelItem').last()
			prevLabel.addClass QUERIED_CLASS

		else
			console.log 'No selectable label in the list!'

export default LabelEditorModalView
