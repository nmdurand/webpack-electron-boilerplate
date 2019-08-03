import 'jquery/src/jquery'
import 'bootstrap/dist/js/bootstrap.min.js'
import 'bootstrap/dist/css/bootstrap.css'
import './styles/main.scss'
import '@fortawesome/fontawesome-pro/css/all.css'

import _ from 'lodash'
import { ipcRenderer, shell, clipboard } from 'electron'
import os from 'os'
import ip from 'ip'
import QRCode from 'qrcode'

KO_CLASS = 'ko'
OK_CLASS = 'ok'

RESIZE_OFFSET = 22

$window = $(window)
$documentBody = $(window.document.body)

# Templates
addressListTemplate = require './templates/addressList.hbs'
dataPathTemplate = require './templates/dataPath.hbs'
layoutTemplate = require './templates/layout.hbs'

shortenPath = (source, maxLength)->
	console.log 'Shortening path', source
	INDICATOR = '...'

	trueMaxLength = maxLength - INDICATOR.length

	if source.length > trueMaxLength
		head = source.substr 0, trueMaxLength/2
		tail = source.substr source.length-(trueMaxLength-head.length-INDICATOR.length)
		head+INDICATOR+tail
	else
		source

openSystemEditor = (path)->
	console.log 'Opening system editor for:',path
	shell.openItem path

showInExplorer = (path)->
	console.log 'Opening in explorer:',path
	shell.showItemInFolder path

result = ipcRenderer.sendSync 'request:server:config'
console.log 'Server config request result:',result

serverError = result.serverError
serverConfig = result.config

console.log 'Received main process config:',serverConfig

document.title = serverConfig.applicationName

console.log '> Appending layout template', $documentBody
$documentBody.append layoutTemplate
	manifest:
		name: serverConfig.applicationName
		version: serverConfig.applicationVersion

$body = $('#body')
$dataPath = $('#dataPath')
$addresses = $('#addresses')
$qrcode = $('#qrcode')


qrCodeOpts =
	errorCorrectionLevel: 'L'
	width: 400

serverUrl = "http://#{ip.address()}:#{serverConfig.port}/"
QRCode.toCanvas serverUrl, qrCodeOpts,
	(err, canvas)->
		if err
			throw err
		$qrcode.append canvas

updateDataPath = (dataPath)->
	console.log 'Updating dataPath:', dataPath
	$dataPath.html dataPathTemplate
		path: dataPath
		shortPath: shortenPath dataPath, 50

updateDataPath serverConfig.contentFolderPath

$documentBody.delegate '#editConfig', 'click', ->
	openSystemEditor serverConfig.configPath

$documentBody.delegate '.dataPath .path', 'click', ->
	showInExplorer serverConfig.contentFolderPath

$documentBody.delegate '.browseButton','click', ->
	ipcRenderer.once 'result:datapath:selection', (event,result)->
		console.log 'Datapath selection result:', result
		{error,selectedPath} = result
		if error
			alert "Error updating config file: #{error.code}"
		updateDataPath selectedPath

	ipcRenderer.send 'request:datapath:selection'

$documentBody.delegate '#exportCSVButton','click', ->
	$exportCSVButton = $ '#exportCSVButton'
	unless $exportCSVButton.hasClass 'disabled'
		$exportCSVButton.addClass 'disabled'

		ipcRenderer.once 'result:csv:export', (event,result)->
			{csvExportPath, error} = result
			if error
				alert "Error exporting csv file: #{error.code}"
			else
				console.log 'CSV export success, path:', csvExportPath
				showInExplorer csvExportPath
			$exportCSVButton.removeClass 'disabled'

		ipcRenderer.send 'request:csv:export'

if serverError
	console.log 'Received server error:',serverError
else
	serverPort = serverConfig.port
	refreshAddresses = (newAddresses)->
		if newAddresses?
			$('.addressList').remove()
			setTimeout (-> # add a little delay to allow proper user feedback
				addresses = [
					"http://localhost:#{serverPort}/"
					"http://#{os.hostname()}:#{serverPort}/"
				]

				for address in newAddresses
					addresses.push "http://#{address}:#{serverPort}/"

				$addresses.append addressListTemplate
					addresses: addresses
			), 100

	$documentBody.delegate '.addressList #refreshButton', 'click', ->
		getIpAddressList (addresses)->
			refreshAddresses addresses

	$documentBody.delegate '.addressList .address', 'click', ->
		address = event.target.dataset.href
		console.log 'Address clicked:',address
		clipboard.writeText address
		alert "Address copied to clipboard."

	getIpAddressList = (callback)->
		ipcRenderer.once "ipAddresses:list", (event, err, addresses)->
			if err
				console.warn 'Error getting ip addresses'
			else
				callback addresses if callback

		ipcRenderer.send "request:ipAddresses"

	ipcRenderer.on 'ipAddresses:change', (event, addresses)->
		refreshAddresses addresses

	getIpAddressList (addresses)->
		refreshAddresses addresses

ipcRenderer.send 'ready'


# require 'typeface-ubuntu'
# import '@fortawesome/fontawesome-free/css/all.css'

# basicTemplate = require './templates/basic.hbs'
# faTemplate = require './templates/fa.hbs'
#
# component = ->
# 	element = document.createElement 'div'
#
# 	element.innerHTML = _.join ['Hello', 'Webpack,', 'Coffeescript,', 'Sass', 'and Handlebars!'], ' '
# 	element.classList.add 'bigBlue'
#
# 	element
#
# renderTemplate = (template,context)->
# 	element = document.createElement 'div'
#
# 	element.innerHTML = template context
#
# 	element
#
# renderFA = (icon)->
# 	style = 's'
# 	renderTemplate faTemplate, {style:style, icon:icon}

# document.body.appendChild component()
# document.body.appendChild renderTemplate(basicTemplate, {myValue: 'This is a rendered hbs template!'})
# document.body.appendChild renderFA('address-book')
# document.body.appendChild renderFA('apple-alt')
