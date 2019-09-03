Nightmare = require 'nightmare'

console.log '>> We\'re here'
nightmare = Nightmare
	electronPath: require '../../../node_modules/electron'
	show: false


nightmare.goto('https://duckduckgo.com').end().then(
	console.log '> My work here is done'
)
# 	.type('#search_form_input_homepage', 'github nightmare')
# 	.click('#search_button_homepage')
# 	.wait('#links .result__a')
# 	.evaluate(() => document.querySelector('#links .result__a').href)
# 	.end()
# 	.then(
# 		console.log '> My work here is done'
# 	)
