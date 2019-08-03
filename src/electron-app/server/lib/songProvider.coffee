_ = require 'lodash'

debug = require('debug')('happi:karaoke:songprovider')
StringUtils = require './string.coffee'

logger = require('log4js').getLogger 'songProvider'

module.exports = (songs)->

	if _.isEmpty songs
		throw new Error 'No songs provided.'

	for song in songs
		unless song.fileError
			song.id = StringUtils.friendlify (song.artist+'-'+song.title), true
			song.searchTitle = StringUtils.normalize song.title
			song.searchArtist = StringUtils.normalize song.artist

			# debug 'Song:',song.title,song.id
			debug 'Song:',song.title,'by',song.artist
		else
			# Handling txt files containing errors (header issues)
			song.id = StringUtils.normalize song.title
			song.searchTitle =  StringUtils.normalize song.title
			song.searchArtist = "error"

	SongProvider =
		get: (searchedId)->
			songs.find (song)->
				song.id is searchedId

		getAllSongs: ->
			songs

		list: ->
			# Renvoyer array d'objets {title, searchTitle, artist, searchArtist, id}
			list = []
			for song in songs
				songEssentials =
					title: song.title
					searchTitle: song.searchTitle
					artist: song.artist
					searchArtist: song.searchArtist
					id: song.id
					file: song.file
					labels: song.labels
					key: song.key
				if song.fileError
					songEssentials.fileError = true
				list.push songEssentials
			list
