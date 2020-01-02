import puppeteer from 'puppeteer'
import $ from 'jquery'

CHROMIUM_PATH = './node_modules/puppeteer/.local-chromium/mac-674921/chrome-mac/Chromium.app/Contents/MacOS/Chromium'
IMDB_TOP1000_PATH = 'https://www.imdb.com/search/title/?title_type=feature&groups=top_1000'

# ASYNC AWAIT needs coffeescript@2 to run
getTop1000MoviesData = ->
	console.log '> Launching headless browser.'
	browser = await puppeteer.launch
		executablePath: CHROMIUM_PATH
		args: ['--lang=en-US, en']
	console.log '> Creating page.'
	page = await browser.newPage()
	data = []
	# for i in [0..19]
	for i in [0..0]
		console.log '> Navigating to url.'
		partialPATH = IMDB_TOP1000_PATH + "&start=#{i*50 + 1}"
		await page.goto(partialPATH)
		await page.addScriptTag
			# path: require.resolve('jquery')
			content: $
		console.log '> Evaluating scraping function in page context.'
		dataSlice = await page.evaluate ->
			console.log 'TEST', $('.lister-item-content')
			try
				$('.lister-item-content').each =>
					console.log '> Yo', this
					path = $(this).find('.lister-item-header a').attr('href')
					title = $(this).find('.lister-item-header a').text()
					plot = $(this).find('.ratings-bar + .text-muted').text()
					data.push
						title: title
						path: path
						plot: plot.trim()

				data
			catch err
				throw err

		data = data.concat dataSlice


	console.log '> Closing headless browser.', data
	await browser.close()
	data

movieProvider =
	getTop1000MoviesData: getTop1000MoviesData

export default movieProvider
