
tonaRegex = /^[A-G][b#]?(-|m|min)?$/
tonalities = [
	names: ['C', 'A-']
	preferredAccidental: ''
,
	names: ['C#', 'Db', 'A#-', 'Bb-']
	preferredAccidental: 'b'
,
	names: ['D', 'B-']
	preferredAccidental: '#'
,
	names: ['D#', 'Eb', 'C-']
	preferredAccidental: 'b'
,
	names: ['E', 'C#-', 'Db-']
	preferredAccidental: '#'
,
	names: ['F', 'D-']
	preferredAccidental: 'b'
,
	names: ['F#', 'Gb', 'D#-', 'Eb-']
	preferredAccidental: '#'
,
	names: ['G', 'E-']
	preferredAccidental: '#'
,
	names: ['G#', 'Ab', 'F-']
	preferredAccidental: 'b'
,
	names: ['A', 'F#-', 'Gb-']
	preferredAccidental: '#'
,
	names: ['A#', 'Bb', 'G-']
	preferredAccidental: 'b'
,
	names: ['B', 'G#-', 'Ab-']
	preferredAccidental: '#'
]

# Define positive modulus function
modulus = (n,m)->
	((n % m) + m) % m

Tonality =
	getTonalityIndex: (name)->
		unless tonaRegex.test name
			throw new Error "Couldn't initialize tonality, invalid name."
		else
			normalizedName = name.replace /(m|min)/, '-'
			tonalities.findIndex (tona)->
				tona.names.includes normalizedName

	getPreferredAccidental: (index)->
		index = modulus index, tonalities.length
		tonalities[index].preferredAccidental

	getTonalityNames: (index)->
		index = modulus index, tonalities.length
		tonalities[index].names


export default Tonality
