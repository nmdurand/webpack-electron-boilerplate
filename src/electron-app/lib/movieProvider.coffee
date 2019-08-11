import puppeteer from 'puppeteer'
import $ from 'jquery'

IMDB_TOP1000_PATH = 'https://www.imdb.com/search/title/?title_type=feature&groups=top_1000'

# ASYNC AWAIT needs coffeescript@2 to run
getTop1000MoviesData = ->
	console.log '> Launching headless browser.'
	browser = await puppeteer.launch
		args: ['--lang=en-US, en']
	console.log '> Creating page.'
	page = await browser.newPage()
	data = []
	for i in [0..19]
		console.log '> Navigating to url.'
		partialPATH = IMDB_TOP1000_PATH + "&start=#{i*50 + 1}"
		await page.goto(partialPATH)
		console.log '> Evaluating scraping function in page context.'
		dataSlice = await page.evaluate =>
			try
				data = []
				$('.lister-item-content').each ->
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
	browser.close()
	data

movieProvider =
	getTop1000MoviesData: getTop1000MoviesData

export default movieProvider
