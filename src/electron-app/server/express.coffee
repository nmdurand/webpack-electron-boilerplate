import express from 'express'
import path from 'path'
import ip from 'ip'
import socketIo from 'socket.io'
import http from 'http'


PORT = 3000


app = express()
server = http.createServer app
io = socketIo server,
	serveClient: false

# io = socket.listen server
console.log '>> Initialized socket.io!'
io.on 'connection', (client)->
	console.log 'Client connected to the server!'

	client.emit 'news',
		hello: 'world'

	client.on 'testEvent', (data)->
		console.log(data);


DIST_DIR = path.join __dirname, './public'
HTML_FILE = path.join DIST_DIR, 'index.html'
app.use express.static(DIST_DIR)


app.get '/', (req, res) ->
	# res.send 'Tu peux pas test!'
	res.sendFile HTML_FILE

server.listen PORT, ->
	console.log "Example app listening on port #{PORT}!"
	console.log "Local ip:", ip.address()


export default app
