import $ from 'jquery'
import Marionette from 'backbone.marionette'
import Focus from './focus.coffee'
import 'bootstrap' # Make sure bootstrap is loaded

createRegion = ->
	# $el = $('<div class="modal fade" role="dialog">') # Removed 'fade' class that prevents 'shown' event from firing.
	$el = $('<div class="modal" role="dialog" data-backdrop="true" tabindex="-1"></div>') # tabindex is required to allow closing modal with 'escape' key.
	$el.appendTo document.body

	new Marionette.Region
		el: $el

region = createRegion()
currentView = false

region.$el.on 'hidden.bs.modal', ->
	console.log 'Modal is hidden.'
	region.empty() # remove dom structure on close.

region.$el.on 'show.bs.modal', ->
	console.log 'Modal show.'
	region.currentView?.triggerMethod 'modal:show'

region.$el.on 'shown.bs.modal', ->
	console.log 'Modal is shown.'
	region.currentView?.triggerMethod 'modal:shown'

region.$el.on 'hide.bs.modal', ->
	region.currentView?.triggerMethod 'modal:hide'

region.$el.on 'hidden.bs.modal', ->
	region.currentView?.triggerMethod 'modal:hidden'

showModal = ->
	region.$el.modal()

hideModal = ->
	region.$el.modal('hide')

stopListening = ->
	if currentView
		currentView.off 'attach'
		currentView.off 'modal:close'

Modal =
	show: (view)->
		Focus.clear()
		stopListening()

		view.on 'attach', ->
			showModal()

		view.on 'modal:close', ->
			hideModal()
			stopListening()
			currentView = false

		region.show view
		currentView = view

	hide: ->
		hideModal()
		stopListening()
		currentView = false


export default Modal
