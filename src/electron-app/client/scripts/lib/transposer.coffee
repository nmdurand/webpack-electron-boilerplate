import tonality from './tonality.coffee'
import parser from './parser.coffee'
import Chord from './chord.coffee'


Transposer =
	transposeChord: (chordStr, tona, transpo)->
		chord = new Chord chordStr
		tonaIndex = tonality.getTonalityIndex tona
		transposedIndex = tonaIndex + transpo
		preferredAccidental = tonality.getPreferredAccidental transposedIndex

		chord.setTranspo transpo
		chord.setPreferredAccidental preferredAccidental

		chord.getName()

	transposeTune: (tune, transpo)->
		chordList = parser.stringToChordList tune.chords

		tonaIndex = tonality.getTonalityIndex tune.tonality
		transposedIndex = tonaIndex + transpo
		preferredAccidental = tonality.getPreferredAccidental transposedIndex

		result = chordList.map (chord)->
			chord.setTranspo transpo
			chord.setPreferredAccidental preferredAccidental
			chord

		transposedTune = parser.chordListToString result

		transposedTune


export default Transposer
