express = require 'express'
path = require 'path'
app = express()
port = 3000

HTML_FILE = path.join __dirname, '../client/index.html'

app.get '/', (req, res) ->
	res.sendFile(HTML_FILE)

app.listen port, ->
	console.log "Example app listening on port #{port}!"
