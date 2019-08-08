import _ from 'lodash'
import './styles/style.scss'
require 'typeface-ubuntu'
import '@fortawesome/fontawesome-free/css/all.css'
import io from 'socket.io-client'

basicTemplate = require './templates/basic.hbs'
faTemplate = require './templates/fa.hbs'

component = ->
	element = document.createElement 'div'

	element.innerHTML = _.join ['Hello', 'Webpack,', 'Coffeescript,', 'Sass', 'and Handlebars!'], ' '
	element.classList.add 'bigBlue'

	element

renderTemplate = (template,context)->
	element = document.createElement 'div'

	element.innerHTML = template context

	element

renderFA = (icon)->
	style = 's'
	renderTemplate faTemplate, {style:style, icon:icon}

document.body.appendChild renderTemplate(basicTemplate, {myValue: 'My hbs template is rendered!'})
document.body.appendChild renderFA('air-freshener')
document.body.appendChild renderFA('ambulance')


# Set up socket.io client-side :
socket = io()
socket.emit 'testEvent', 'Emitted by the client'
socket.on 'news', (data)->
	console.log '> Got news:', data
