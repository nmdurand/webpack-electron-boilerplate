semver = require 'semver'
fs = require 'fs'

LIVERELOAD_PORT = process.env.LRPORT || 35729

currentNodeVersion = process.version
expectedNodeVersion = fs.readFileSync '.nvmrc','utf-8' # must specify encoding to read as text.
if expectedNodeVersion and not semver.satisfies currentNodeVersion,expectedNodeVersion
	colors = require 'colors'
	console.error "Invalid node version. Expected: #{expectedNodeVersion} found: #{currentNodeVersion}".red
	process.exit 1

module.exports = (grunt)->
	# Load grunt tasks automatically
	require('load-grunt-tasks')(grunt)

	path = require 'path'

	nodeExternals = require 'webpack-node-externals'
	CopyPlugin = require 'copy-webpack-plugin'
	HtmlWebpackPlugin = require 'html-webpack-plugin'
	# webpack = require 'webpack'


	packageInfo = require './package.json'

	DIST_PATH = 'dist'
	BUILD_PATH = 'build'

	# Define the configuration for all the tasks
	grunt.initConfig

		packageInfo: packageInfo
		electronVersion: packageInfo.devDependencies['electron']

		clean:
			dist: DIST_PATH
			build: BUILD_PATH

		webpack:

			elMain:
				mode: 'development'
				# mode: 'production'
				context: path.join __dirname,'src/main'
				entry: './main.coffee'
				output:
					filename: 'main.js'
					path: path.resolve __dirname, BUILD_PATH
				target: 'electron-main'
				externals: [nodeExternals()]
				node:
					__dirname: false,
					__filename: false
				module:
					rules: [
						test: /\.coffee$/,
						loader: 'coffee-loader'
					]
				plugins:[
					new CopyPlugin([
						from: path.join __dirname,'package.json'
					])
				]

			elRenderer:
				mode: 'development'
				# mode: 'production'
				context: path.join __dirname,'src/renderer'
				entry: './scripts/main.coffee'
				output:
					filename: 'renderer.js'
					path: path.join __dirname, BUILD_PATH, 'renderer'
				target: 'electron-renderer'
				devtool: 'inline-source-map'
				module:
					rules: [
						test: /\.s?css$/
						use: [
							'style-loader',
							'css-loader',
							'sass-loader'
						]
					,
						test: /\.coffee$/
						use: [ 'coffee-loader' ]
					,
						test: /\.hbs$/
						use: [ 'handlebars-loader' ]
					,
						test: /\.(woff(2)?|ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
						use: [
								loader: 'file-loader'
								options:
									name: '[name].[ext]'
									outputPath: 'fonts/'
						]
					,
						test: /\.(png|svg|jpg|gif)$/
						use: [
								loader: 'file-loader'
								options:
									outputPath: 'images/'
						]
					]
				plugins: [
					new HtmlWebpackPlugin
						template: 'index.html'
				]
				resolve:
					extensions: ['.js','.coffee','.hbs']
					modules: ['scripts','node_modules']

		exec:
			rebuildElectronModules:
				command: "npx electron-rebuild -v #{grunt.config.get('electronVersion')} -f -e node_modules/electron"

			electron:
				command: "npx electron #{BUILD_PATH}"

		electron:
			options:
				'appBundleId': packageInfo.applicationId
				name: packageInfo.displayName
				dir: path.resolve __dirname, BUILD_PATH
				out: path.resolve __dirname, DIST_PATH
				electronVersion: grunt.config.get 'electronVersion' # use same version as during dev.
				appVersion: packageInfo.version
				asar: false
				# asar: true
				overwrite: true
				# icon: 'images/icon'
				prune: true
			osx:
				options:
					platform: 'darwin'
					arch: 'x64'


	grunt.registerTask 'elserve', [
		'clean'

		'webpack:elMain'
		'webpack:elRenderer'

		'exec:electron'
	]

	grunt.registerTask 'dist', [
		'clean'

		'exec:rebuildElectronModules'

		'webpack:elMain'
		'webpack:elRenderer'

		'electron'
	]
