import Chord from './chord.coffee'

blankRegexp = /\s+/

Parser =

	stringToChordList: (str)->
		list = str.split blankRegexp
		result = []
		list.forEach (chord)->
			result.push new Chord(chord)

		result


	chordListToString: (chordList)->
		result = ""
		chordList.forEach (chord)->
			result += ' ' + chord.getName()

		result


export default Parser
