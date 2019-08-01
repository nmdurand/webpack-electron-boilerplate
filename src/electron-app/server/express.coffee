express = require 'express'
path = require 'path'
PORT = 3000


app = express()
DIST_DIR = path.join __dirname, './public'
HTML_FILE = path.join DIST_DIR, 'index.html'
app.use express.static(DIST_DIR)

app.get '/', (req, res) ->
	# res.send 'Tu peux pas test!'
	res.sendFile HTML_FILE

app.listen PORT, ->
	console.log "Example app listening on port #{PORT}!"

module.exports = app
