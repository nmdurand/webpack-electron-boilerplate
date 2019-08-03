import Marionette from 'backbone.marionette'
import Modal from '../../lib/modal.coffee'

class LoginModalView extends Marionette.View
	className: 'login-modal modal-dialog'
	template: require '../../templates/setup/loginModal.hbs'

	ui:
		submitButton: '.submitButton'
		textInput: '.text-input'
		modalBackdrop: '.login-modal'

	events:
		'click @ui.submitButton': 'submitCode'
		# 'keypress': 'handleKeypress'
		'click @ui.modalBackdrop': 'closeModal'

	initialize: ->
		$(document).on 'keydown', @handleKeydown

	onDestroy: ->
		$(document).off 'keydown'

	@show: (options)->
		modalView = new LoginModalView

		modalView.on 'submit', options.selectionCallback

		console.log 'Showing modal view'
		Modal.show modalView

	submitCode: ->
		code = @ui.textInput.val()
		@trigger 'submit', code
		@closeModal()

	handleKeydown: (e)=>
		code = e.keyCode
		if code is 13
			e.preventDefault()
			@submitCode()

	closeModal: =>
		Modal.hide @


export default LoginModalView
