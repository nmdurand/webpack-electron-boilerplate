import _ from 'lodash'

notes = [
	['C']
	['C#', 'Db']
	['D']
	['D#', 'Eb']
	['E']
	['F']
	['F#', 'Gb']
	['G']
	['G#', 'Ab']
	['A']
	['A#', 'Bb']
	['B']
]

# Define positive modulus function
modulus = (n,m)->
	((n % m) + m) % m

Note =

	transpose: (note, semitones, preferredAccidental = '#')->
		if _.isEmpty note
			# console.log 'Empty note transposition requested.'
			return note
		else if semitones is 0
			# console.log '0 semitones transposition requested.'
			return note
		else
			noteIndex = _.findIndex notes, (noteArray)->
				noteArray.includes note

			if noteIndex is -1
				console.log "Error: couldn't transpose note.", note
				return note
			else
				noteIndex = modulus (noteIndex + semitones), notes.length

				transposedNotes = notes[noteIndex]
				if transposedNotes.length is 1
					return transposedNotes[0]
				else
					tester = new RegExp preferredAccidental
					result = _.find transposedNotes, (noteName)-> tester.test noteName
					if result?
						return result
					else
						return transposedNotes[0]


export default Note
