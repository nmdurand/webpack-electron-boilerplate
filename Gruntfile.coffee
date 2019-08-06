

module.exports = (grunt)->
	# Load grunt tasks automatically
	require('load-grunt-tasks')(grunt)

	path = require 'path'
	nodeExternals = require 'webpack-node-externals'
	CopyPlugin = require 'copy-webpack-plugin'
	HtmlWebpackPlugin = require 'html-webpack-plugin'
	webpack = require 'webpack'


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
				# mode: 'development'
				mode: 'production'
				entry: './src/electron-app/main.coffee'
				output:
					filename: 'main.js'
					path: path.resolve __dirname, BUILD_PATH
				# target: 'electron-main'
				target: 'node'
				externals: [
					nodeExternals(
						# whitelist: [ 'log4js', 'network']
					)
					# "network": "require('network')"

				]
				# externals: [
				# 	nodeExternals(
				# 		whitelist: [
				# 			'log4js'
				# 			'socket.io'
				# 		])
				# ]
				# externals: [
				# 	log4js: "require('log4js')"
				# 	'socket.io': "require('socket.io')"
				# ]
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
						from: './package.json',
						to: './package.json'
					])
				]


			elRenderer:
				# mode: 'development'
				mode: 'production'
				entry: './src/electron-app/renderer/index.coffee'
				output:
					filename: 'renderer.js'
					path: path.join __dirname, BUILD_PATH, 'renderer'
				target: 'electron-renderer'
				devtool: 'inline-source-map'
				module:
					rules: [
						test: /\.css$/
						use: [
							'style-loader',
							'css-loader'
						]
					,
						test: /\.s(c|a)ss$/
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
						template: "./src/electron-app/renderer/index.html"
				]


			public:
				# mode: 'development'
				mode: 'production'
				entry: './src/electron-app/client/main.coffee'
				output:
					filename: 'main.js'
					path: path.resolve __dirname, BUILD_PATH, 'public'
				target: 'electron-renderer'
				devtool: 'inline-source-map'
				module:
					rules: [
						test: /\.css$/
						use: [
							'style-loader',
							'css-loader'
						]
					,
						test: /\.s(c|a)ss$/
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
						test: /\.(woff(2)?|ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/
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
				# externals: [ /^socket$/ ]
				plugins: [
					new HtmlWebpackPlugin
						template: "./src/electron-app/client/index.html"
				,
					new CopyPlugin [
						from: './src/electron-app/client/images/favicon.ico',
						to: './images/favicon.ico'
					]
				,
					new webpack.ProvidePlugin
						$: "jquery",
						jQuery: "jquery"
				]


		exec:
			rebuildElectronModules:
				command: 'npx electron-rebuild -v <%= electronVersion %> -f -e node_modules/electron'

			electron:
				command: "npx electron #{BUILD_PATH}"

		electron:
			options:
				'appBundleId': packageInfo.applicationId
				name: packageInfo.displayName
				dir: BUILD_PATH
				out: DIST_PATH
				electronVersion: '<%= electronVersion %>' # use same version as during dev.
				appVersion: packageInfo.version
				asar: false
				# asar: true
				overwrite: true
				icon: 'images/icon'
				prune: true
			osx:
				options:
					platform: 'darwin'
					arch: 'x64'


	grunt.registerTask 'elserve', [
		'clean:build'

		'webpack:elMain'
		'webpack:elRenderer'
		'webpack:public'

		'exec:electron'
	]

	grunt.registerTask 'dist', [
		'clean'

		'exec:rebuildElectronModules'

		'webpack:elMain'
		'webpack:elRenderer'
		'webpack:public'

		'electron'
	]
