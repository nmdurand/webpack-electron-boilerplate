import Marionette from 'backbone.marionette'
import _ from 'lodash'

HIDDEN_CLASS = 'hidden'

class StatusBarView extends Marionette.View
	template: require '../../templates/common/statusBar.hbs'
	className: 'statusWrapper'

	events:
		'click': 'displayCurrentSongClick'

	initialize: ->
		console.log 'Initializing status view with options:', @options
		{@title,@artist} = @options

	onRender: ->
		unless @hasSong()
			@$el.addClass HIDDEN_CLASS
		else
			@$el.removeClass HIDDEN_CLASS

	templateContext: =>
		title: @title
		artist: @artist

	hasSong: =>
		not _.isEmpty @title

	displayCurrentSongClick: ->
		@trigger 'display:current:song'


export default StatusBarView
