import _ from 'lodash'
import Note from './note.coffee'

chordParseRegex = /^([ABCDEFG][b#]?|)([^\/]*)(\/([ABCDEFG][#b]?|))?$/
rootRegex = /^([ABCDEFG][#b]?)$/

class Chord
	constructor: (options)->
		# Set root, ext and bass
		if _.isString options
			# console.log 'Initializing new chord:', options
			# Initialization with chord name
			parseResult = chordParseRegex.exec options
			if parseResult?
				@root = parseResult[1] if parseResult[1]?
				@ext = parseResult[2] if parseResult[2]?
				@bass = parseResult[4] if parseResult[4]?
		else
			# console.log 'Initializing new chord with options:', options
			# Initialization with proper options
			{root, ext, bass, transpo, preferredAccidental} = options

			root ?= ''
			@setRoot(root)
			@setExt(ext) if ext?
			@setBass(bass) if bass?
			@setTranspo(transpo) if transpo?
			@setPreferredAccidental(preferredAccidental) if preferredAccidental?

	getRoot: ->
		# if @root is ''
		# 	''
		# else
		transpo = @getTranspo()
		# result = ''
		# if transpo?
		Note.transpose(@root, transpo, @getPreferredAccidental())
		# else
		# 	@root

	getExt: ->
		@ext

	getBass: ->
		if @bass?
			transpo = @getTranspo()
			if transpo?
				Note.transpose @bass, transpo, @getPreferredAccidental()
			else
				@bass
		else
			@getRoot()

	getTranspo: ->
		@transpo

	getPreferredAccidental: ->
		@preferredAccidental

	getName: ->
		name = @getRoot() + @getExt()
		if @bass?
			name += '/' + @getBass()
		name

	setRoot: (newRoot)->
		@root = newRoot

	setExt: (newExt)->
		@ext = newExt

	setBass: (newBass)->
		@bass = newBass

	setTranspo: (newTranspo)->
		@transpo = newTranspo

	setPreferredAccidental: (newPreferredAccidental)->
		@preferredAccidental = newPreferredAccidental


export default Chord
