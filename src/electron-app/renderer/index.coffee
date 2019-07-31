import _ from 'lodash'
import $ from 'jquery'
import './styles/style.scss'
require 'typeface-ubuntu'
require 'typeface-ubuntu-mono'
import '@fortawesome/fontawesome-free/css/all.css'

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

document.body.appendChild component()
document.body.appendChild renderTemplate(basicTemplate, {myValue: 'This is a rendered hbs template!'})
document.body.appendChild renderFA('address-book')
document.body.appendChild renderFA('apple-alt')
