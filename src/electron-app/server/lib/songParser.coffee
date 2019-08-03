fs = require 'fs'
_ = require 'lodash'
path = require 'path'

# SONG_FOLDER = '/../../../songs'
CHORD_REGEX = /^([A-G][b#]?|%)([^\/]*)(\/([A-G][b#]?))?$/

parseChord = (chordIndex, chordName)->
	result =
		index: chordIndex

	if chordName.charAt(0) is '<'
		result.alignRight = true
		chordName = chordName.substr 1

	if chordName.match /_/
		result.small = true
		chordName = chordName.replace(/_/g,' ')

	result.name = normalizeChord chordName

	result

normalizeChord = (chordName)->
	chordName = chordName.replace(/maj7/gi,'Δ')
	chordName = chordName.replace(/M7/g,'Δ')
	chordName = chordName.replace(/maj/gi,'')
	chordName = chordName.replace(/(m|min|-)7b5/gi,'Ø7')
	chordName = chordName.replace(/(min)/gi,'-')
	chordName = chordName.replace(/dim|dim7|7dim/gi,'°')
	chordName = chordName.replace(/m/gi,'-')
	chordName = chordName.replace(/aug/gi,'+')
	chordName

processChord: (chordName)->
	chordParts = CHORD_REGEX.exec chordName
	chordData.root = chordParts[1]
	if chordParts[2]
		chordData.extension = chordParts[2]
	if chordParts[4]
		chordData.altRoot = chordParts[4]

	chordData

parseChordLine = (chordLine)->
	chords = []
	startIndex = -1
	for i in [0..chordLine.length-1]
		if chordLine.charAt(i) isnt ' '
			if startIndex < 0
				startIndex = i
		else
			if startIndex >= 0
				chords.push parseChord(startIndex, chordLine.substring(startIndex,i))
				startIndex = -1
	# If chordLine string ends with a chord, flush the remaining data
	if startIndex >= 0
		chords.push parseChord startIndex, chordLine.substring(startIndex,i)

	chords

parseLyricLine = (lyricLine)->
	lyrics = ''
	chordIndexes=[]
	for i in [0..lyricLine.length]
		# Record '@' placement, if present in the text
		if lyricLine.charAt(i) is '@'
			# Shift recorded '@' char indexes
			chordIndexes.push i - chordIndexes.length
		else
			lyrics += lyricLine.charAt(i)

	text: lyrics
	chordIndexes: chordIndexes

generateSpaces = (length)->
	result = ''
	result += ' ' while result.length < length
	result

getLineData = (chordData,lyricData)->
	# Replace chord indexes when needed !
	chordDataUpdated = chordData
	for index, i in lyricData.chordIndexes
		chordDataUpdated[i].index = index
	text=''
	if _.isEmpty lyricData.text
		lastChordIndex = chordData[chordData.length-1].index
		text = generateSpaces Math.max(lastChordIndex-7,0)
		text = '( ... )'+text
	else
		text = lyricData.text
	text: text
	chords: chordDataUpdated

getEmptyLine = ->
	text: ""
	chords: []

getCommentLine = (line)->
	resultLine = line
	text: resultLine.slice(1)
	isComment: true

parseFile = (path)->
	new Promise((resolve,reject)->
		fs.readFile path, 'utf-8', (err,data)->
			if err
				reject err
			else
				resolve data
	).then((data)->
		data.split /\r?\n/
	).then((splitData)->
		songData = {}
		[songData.title,songData.artist,songData.key,songData.labels,songData.content...] = splitData

		songLabels = songData.labels
		songLabels = songLabels.trim()
		unless _.isEmpty songLabels
			songLabels = songLabels.toLowerCase()
			songData.labels = songLabels.split /\s+/
		else
			songData.labels = []

		if (_.isEmpty songData.title) or (_.isEmpty songData.artist) or (_.isEmpty songData.key)
			return Promise.reject new Error 'Missing song data (title, artist or key)'

		songData
	).then((songData)->
		content = songData.content
		# enlever lignes vides au début et à la fin des fichiers
		while _.isEmpty content[0]
			content.shift()

		while _.isEmpty content[content.length-1]
			content.pop()

		# Ajouter une dernière ligne vide (pour le cas où le morceau finit par des accords)
		content.push ""

		# Parser le fichier, ligne par ligne
		lines = []
		afterEmptyLine = false
		afterChordLine = false
		for i, line of content
			isCurrentLineEmpty = _.isEmpty line
			if afterChordLine
				# Après une ligne d'accords, on considère que c'est toujours une ligne de paroles
				chordLine = content[i-1]
				lyricLine = line

				newLine = getLineData parseChordLine(chordLine), parseLyricLine(lyricLine)

				lines.push newLine
				afterChordLine = false
			else
				if isCurrentLineEmpty
					if not afterEmptyLine
						newLine = getEmptyLine()
						lines.push newLine
						# On garde la première ligne vide
					# else Rien (on supprime les lignes vides consécutives)
					afterEmptyLine = true
				else if line.charAt(0) == '#'
					newLine = getCommentLine line
					# On conserve les commentaires (lignes commençant par #)
					lines.push newLine
					afterEmptyLine = false
				else
					# Une ligne d'accords ; on le note et
					# on s'en occupe au prochain tour...
					afterChordLine = true
					afterEmptyLine = false

		# On ajoute une propriété 'index' à toutes les lignes
		indexedLines = translateSongData lines
		for line, i in indexedLines
			indexedLines[i].lineIndex = i

		title: songData.title
		artist: songData.artist
		labels: songData.labels
		key: normalizeChord songData.key
		lines: indexedLines
	)

translateSongData = (data)->
	result = []
	for line in data
		if line.isComment
			result.push line
		else
			if _.isEmpty(line.chords) and _.isEmpty(line.text)
				result.push
					isLinebreak: true
			else
				lineResult = []
				lastIndex = 0
				lineText = line.text
				for chord in line.chords
					chord.isChord = true
					if chord.index > lineText.length
						lineText = lineText + generateSpaces(chord.index-lineText.length)
					linePart = lineText.substring lastIndex, chord.index
					lastIndex = chord.index
					lineResult.push linePart
					lineResult.push chord
				if lineText isnt ''
					lineResult.push lineText.substring lastIndex
				result.push
					lineContent:lineResult
	# console.log 'Translated Data:',result
	result

module.exports =
	parseFolder: (folder)->
		new Promise((resolve,reject)->
			fs.readdir folder, (err,fileList)->
				if err
					reject err
				else
					resolve fileList
		).then((fileList)->
			promise = Promise.resolve()
			songArray = []

			for file in fileList
				if /.txt$/.exec file
					do (file)->
						promise = promise.then ->
							parseFile(path.join folder, file).catch((err)->
								# Promise.reject new Error "Error processing file [#{file}]: #{err.message}"
								console.log "Error processing file [#{file}]: #{err.message}"
								ERRORDATA =
									fileError: true
									file: file
									title: /(.*).txt$/.exec(file)[1]
									artist: ""
									key: ""
									lines: [""]
							).then((parsedData)->
								parsedData.file = file
								songArray.push parsedData
							)
				else
					console.log 'Rejected file:',file
			promise.then(->
				songArray
			)
		)
