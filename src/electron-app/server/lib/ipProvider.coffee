import ip from 'ip'

IpProvider =
	getIp: ->
		ip.address()


export default IpProvider
