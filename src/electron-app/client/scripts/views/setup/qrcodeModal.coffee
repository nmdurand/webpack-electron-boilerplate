import Marionette from 'backbone.marionette'
import Modal from '../../lib/modal.coffee'
import QRCode from 'qrcode'

SERVER_PORT = 8081

class QRCodeModalView extends Marionette.View
	className: 'qrcode-modal modal-dialog'
	template: require '../../templates/setup/qrcodeModal.hbs'

	ui:
		qrcode: '.qrcode'

	events:
		'click @ui.modalBackdrop': 'closeModal'

	initialize: ->
		console.log 'Initializing qrcode Modal view.', @options
		{@ipAddress} = @options

		@serverUrl = "http://#{@ipAddress}:#{SERVER_PORT}/"

	templateContext: ->
		address: @serverUrl

	onRender: ->
		@displayQRCode()

	@show: (options)->
		modalView = new QRCodeModalView options

		console.log 'Showing modal view'
		Modal.show modalView

	closeModal: =>
		Modal.hide @

	displayQRCode: =>
		qrCodeOpts =
			errorCorrectionLevel: 'L'
			width: 400

		QRCode.toCanvas @serverUrl, qrCodeOpts,
			(err, canvas)=>
				if err
					throw err
				@ui.qrcode.append canvas

export default QRCodeModalView