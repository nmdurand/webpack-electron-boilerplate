import Marionette from 'backbone.marionette'
import Modal from '../../lib/modal.coffee'
import Tonality from '../../lib/tonality.coffee'
import $ from 'jquery'

keys =
	major: ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']
	minor: ['A-', 'Bb-', 'B-', 'C-', 'C#-', 'D-', 'D#-', 'E-', 'F-', 'F#-', 'G-', 'G#-']

class KeyChangeModalView extends Marionette.View
	className: 'keychange-modal modal-dialog'
	template: require '../../templates/common/keychangeModal.hbs'

	ui:
		keySelector: '.keySelector'
		keyItem: '.keyItem'
		modalBackdrop: '.keychange-modal'

	events:
		'click @ui.modalBackdrop': 'closeModal'
		'click @ui.keyItem': 'handleKeyItemClick'

	initialize: ->
		console.log 'Initializing keychange modal view.', @options
		{@key, @transpo} = @options
		unless @key?
			# Default key: C
			@key = 'C'
		unless @transpo?
			# Default transpo value: 0
			@transpo = 0

		@tonaIndex = Tonality.getTonalityIndex @key
		# Positive modulus
		@transposedTonaIndex = (((@tonaIndex + @transpo) % 12) + 12) % 12

	onRender: ->
		@populateSelector()

	populateSelector: ->
		if keys.minor.includes @key
			availableKeys = keys.minor
		else
			availableKeys = keys.major

		for key, index in availableKeys
			keyItem = $("<div class='keyItem' data-key='#{key}' data-index='#{index}'>#{key}</div>")
			if key is availableKeys[@tonaIndex]
				keyItem.addClass 'original'
			if key is availableKeys[@transposedTonaIndex]
				keyItem.addClass 'selected'

			@ui.keySelector.append keyItem

	@show: (options)->
		modalView = new KeyChangeModalView options

		modalView.on 'submit', options.selectionCallback

		console.log 'Showing modal view'
		Modal.show modalView

	closeModal: =>
		Modal.hide @

	handleKeyItemClick: (e)->
		console.log 'keyItem clicked:', e.target.dataset.key
		newTranspoValue = e.target.dataset.index - @tonaIndex
		@trigger 'submit', newTranspoValue
		@closeModal()

export default KeyChangeModalView
