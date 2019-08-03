import Marionette from 'backbone.marionette'
import Backbone from 'backbone'
import StringUtils from '../../utils/string.coffee'
import _ from 'lodash'

class HeaderView extends Marionette.View
	template: require '../../templates/common/header.hbs'
	className: 'header'
	ui:
		headerSearchfield:'#header-searchfield'
		searchfieldInput: '.songSearchfield'
		searchfieldEmptyButton: '#header-searchfield.query-present .input-group-addon'
		searchfieldSearchButton: '#header-searchfield:not(.query-present) .input-group-addon'

		headerBackButton: '#header-backButton'
		headerBrandContent: '#header-brand a'
		headerLabelList: '#header-labels .labelList'

	events:
		'keyup @ui.searchfieldInput': 'handleTextInputEvent'
		'click @ui.searchfieldEmptyButton': 'handleRemoveQueryClick'
		'click @ui.searchfieldSearchButton': 'handleSearchClick'

		'click .editLabelsButton': 'handleClickOnEditLabelsButton'
		'click .label': 'handleClickOnLabel'

		'click #header-backButton': 'handleBackButtonClick'

		'click .controlItem.login': 'handleLoginClick'
		'click .controlItem.toggleChords': 'handleChordsClick'
		'click .controlItem.keychange': 'handleKeychangeClick'
		'click .controlItem.qrcode': 'handleQRCodeClick'

	handleBackButtonClick: ->
		@trigger 'display:song:list'

	handleLoginClick: ->
		@trigger 'open:log:modal'

	handleChordsClick: ->
		@trigger 'toggle:chords'

	handleKeychangeClick: ->
		@trigger 'open:keychange:modal'

	handleQRCodeClick: ->
		@trigger 'open:qrcode:modal'

	handleTextInputEvent: (event)->
		@trigger 'filter:list', StringUtils.normalize @ui.searchfieldInput.val()
		@updateSearchFieldIcons()

	handleClickOnLabel: (e)->
		console.log 'click on label.'
		@trigger 'remove:label', e.target.dataset.label

	handleClickOnEditLabelsButton: ->
		console.log 'Click on edit labels button.'
		@trigger 'edit:labels'

	setSearchField: (query)->
		@ui.searchfieldInput.val query
		@updateSearchFieldIcons()
		@trigger 'filter:list', query

	updateSearchFieldIcons: ->
		if _.isEmpty @ui.searchfieldInput.val()
			@ui.headerSearchfield.removeClass 'query-present'
		else
			@ui.headerSearchfield.addClass 'query-present'

	setTitle: (title)->
		console.log 'Setting title', '\"'+title+'\"'
		@ui.headerBrandContent.text title

	setFilterLabels: (labels)->
		@ui.headerLabelList.empty()
		for label in labels
			@ui.headerLabelList.append "<div class='label' data-label='#{label}'>#{label}<i class='labelIcon fas fa-times-circle fa-fw'></i></div>"

	updateMenuItemState: (itemId, state)->
		if state
			@.$(".controlItem.#{itemId}").addClass 'active'
		else
			@.$(".controlItem.#{itemId}").removeClass 'active'

	focusOnSearchfield: =>
		console.log 'Focusing on search field'
		setTimeout (=>
			@ui.searchfieldInput.focus()
			), 0

	blurSearchfield: =>
		@ui.searchfieldInput.blur()

	handleRemoveQueryClick: ->
		@setSearchField ''

	handleSearchClick: =>
		@focusOnSearchfield()

export default HeaderView
