import express from 'express'
import path from 'path'
import ip from 'ip'


PORT = 3000


expressServer = express()
DIST_DIR = path.join __dirname, './public'
HTML_FILE = path.join DIST_DIR, 'index.html'
expressServer.use express.static(DIST_DIR)

expressServer.get '/', (req, res) ->
	# res.send 'Tu peux pas test!'
	res.sendFile HTML_FILE

expressServer.listen PORT, ->
	console.log "Example app listening on port #{PORT}!"
	console.log "Local ip:", ip.address()

export default expressServer
