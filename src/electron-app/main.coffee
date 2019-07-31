import path from 'path'
import url from 'url'
import { app, BrowserWindow } from 'electron'

win = null

require path.resolve('../server/express')

app.on 'ready', ->
	win = new BrowserWindow()

	win.loadURL(
		url.format
			pathname: path.join __dirname, "./renderer/index.html"
			protocol: "file:"
			slashes: true
	)

	win.show()

	win.on 'closed', ->
		win = null
