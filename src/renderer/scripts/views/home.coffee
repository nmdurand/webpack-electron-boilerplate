import Marionette from 'backbone.marionette'
import template from 'templates/home'

export default class HomeView extends Marionette.View
	className: 'home'
	template: template

	initialize: ->
		console.log 'Initializing HomeView', @options
