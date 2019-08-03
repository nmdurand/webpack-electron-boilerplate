ip = require 'ip'

module.exports =

	getIp: ->
		ip.address()
