import {Application} from 'backbone.marionette'

import HomeView from 'views/home'

export default class GameApp extends Application
	initialize: ->
		console.log 'Initializing application:',@options

	onStart: ->
		console.log 'Application started'
		@showView new HomeView