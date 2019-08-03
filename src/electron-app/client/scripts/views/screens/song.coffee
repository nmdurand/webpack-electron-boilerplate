import Marionette from 'backbone.marionette'
import _ from 'lodash'
import Transposer from '../../lib/transposer.coffee'

LINE_FOCUS_TRANSITION_DELAY = 300
CHORD_REGEX = /^([A-G][b#]?|)([^\/\s]*)(?:\/([A-G][b#]?))?$/

class SongLine extends Marionette.View
	tagName: 'div'
	className: 'line'
	template: require '../../templates/screens/songLine.hbs'
	triggers:
		'click': 'select:line'
	ui:
		line: '.line'

	getIndex: ->
		@model.get 'lineIndex'

	isLinebreak: =>
		@model.get 'isLinebreak'


class SongView extends Marionette.CompositeView
	className: 'songScreen'
	template: require '../../templates/screens/song.hbs'
	childView: SongLine
	childViewContainer: '.songDisplay'
	triggers:
		'click .backButton': 'back'

	ui:
		songDisplay: '.songDisplay'
		songContainer: '#songContainer'

	initialize: ->
		console.log 'Initializing SongView:',@options
		{@songData, @chordToggle, @transpo, @lineFocus} = @options

		@lineFocusIndex = if @lineFocus? then @lineFocus else 0
		@transpose = if @transpo? then @transpo else 0

		@collection = new Backbone.Collection

		@transposeAndSetChords()

	transposeAndSetChords: (transpose)=>
		#  Clone original lines and transpose the chords
		@lines = _.cloneDeep @songData.lines
		@transpose = transpose if transpose?
		for line in @lines
			if line?.lineContent
				for item in line.lineContent
					if item?.isChord
						item.name = @transposeChord item.name
		@collection.reset @lines

	transposeChord: (chordName)=>
		if CHORD_REGEX.test chordName
			chordName = Transposer.transposeChord chordName, @songData.key, @transpose
		else if /\s/.test chordName
			chords = chordName.split /\s/
			result = chords.map (chord)=> @transposeChord chord, @songData.key, @transpose

			chordName = result.join ' '

		chordName

	onAttach: =>
		if @chordToggle
			@ui.songDisplay.removeClass 'noChords'
		@setSongDisplayPadding()
		@focusOnLine @lineFocusIndex

	setSongDisplayPadding: =>
		@$('.songDisplay').css 'padding-top', $(".redLine").position().top
		@$('.songDisplay').css 'padding-bottom', $('.songScreen').height() - $(".redLine").position().top

	# model contains :
	# artist
	# key
	# transpose
	# lines: [lineIndex,(line){chords[{alignRight, index, name, small}], isComment, text}, ...]
	# id
	# searchTitle
	# title

	templateContext: ->
		title: @songData.title
		artist: @songData.artist
		key: @songData.key
		# lines: @songData.indexedLines

	onBack: ->
		@triggerMethod 'back:toSongList'

	toggleChords: (chordsFlag)=>
		# Quand on change de vue, on prend garde à revenir à la ligne en focus
		console.log 'Toggling the chords in Song view:', chordsFlag
		if chordsFlag
			@ui.songDisplay.removeClass 'noChords'
		else
			@ui.songDisplay.addClass 'noChords'
		@focusOnLine @lineFocusIndex

	onChildviewSelectLine: (lineView)->
		@focusOnLineAndBroadcastIndex lineView.getIndex()

	focusOnLineAndBroadcastIndex: (lineIndex)->
		@lineFocusIndex = lineIndex
		@focusOnLine @lineFocusIndex
		@triggerMethod 'broadcast:line:index', @lineFocusIndex

	focusOnLine: (lineIndex)->
		console.log 'Focusing on line', lineIndex
		@lineFocusIndex = lineIndex
		element = @children.findByIndex lineIndex
		lineTopPos = element.$el.position().top
		console.log 'lineTopPos:', lineTopPos
		songDisplayContainerTopPos = $(".songDisplay").position().top
		console.log 'songDisplayContainerTopPos:', songDisplayContainerTopPos
		redLineTopPos = $(".redLine").position().top - parseInt($('#titleBar').css('height'))
		console.log 'redLineTopPos:', redLineTopPos

		@ui.songContainer.animate({
			scrollTop:lineTopPos-redLineTopPos-songDisplayContainerTopPos
		},LINE_FOCUS_TRANSITION_DELAY)

	focusOnCurrentLine: =>
		@focusOnLine @lineFocusIndex

	requestNextLine: ->
		@focusOnLineAndBroadcastIndex @getNextLineIndex()

	requestPreviousLine: ->
		@focusOnLineAndBroadcastIndex @getPreviousLineIndex()

	requestNextParagraph: ->
		@focusOnLineAndBroadcastIndex @getNextParagraphIndex()

	requestPreviousParagraph: ->
		@focusOnLineAndBroadcastIndex @getPreviousParagraphIndex()

	getNextLineIndex: =>
		Math.min(@lineFocusIndex+1, @collection.length-1)

	getPreviousLineIndex: =>
		Math.max(@lineFocusIndex-1, 0)

	getNextParagraphIndex: =>
		index = @lineFocusIndex + 1
		while index < @collection.length-1
			if @children.findByIndex(index).isLinebreak()?
				return index+1
			else
				index += 1
		return @collection.length-1

	getPreviousParagraphIndex: =>
		index = @lineFocusIndex - 2
		while index >= 0
			if @children.findByIndex(index).isLinebreak()?
				return index+1
			else
				index -= 1
		return 0


export default SongView
