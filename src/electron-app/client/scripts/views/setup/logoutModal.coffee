import Marionette from 'backbone.marionette'
import Modal from '../../lib/modal.coffee'

class LogoutModalView extends Marionette.View
	className: 'logout-modal modal-dialog'
	template: require '../../templates/setup/logoutModal.hbs'

	ui:
		submitButton: '.submitButton'
		modalBackdrop: '.logout-modal'

	events:
		'click @ui.submitButton': 'confirmLogout'
		'click @ui.modalBackdrop': 'closeModal'

	initialize: ->
		$(document).on 'keydown', @handleKeydown

	onDestroy: ->
		$(document).off 'keydown'

	@show: (options)->
		modalView = new LogoutModalView

		modalView.on 'submit', options.callback

		console.log 'Showing modal view'
		Modal.show modalView

	confirmLogout: ->
		@trigger 'submit'
		@closeModal()

	closeModal: =>
		Modal.hide @

	handleKeydown: (e)=>
		code = e.keyCode
		if code is 13
			e.preventDefault()
			@confirmLogout()


export default LogoutModalView
