

module.exports = (grunt)->
	# Load grunt tasks automatically
	require('load-grunt-tasks')(grunt)

	path = require 'path'
	nodeExternals = require 'webpack-node-externals'
	CopyPlugin = require 'copy-webpack-plugin'
	HtmlWebpackPlugin = require 'html-webpack-plugin'
	webpack = require 'webpack'


	packageInfo = require './package.json'

	# Define the configuration for all the tasks
	grunt.initConfig

		packageInfo: packageInfo
		electronVersion: packageInfo.devDependencies['electron']

		webpack:

			elMain:
				mode: 'development'
				entry: './src/electron-app/main.coffee'
				output:
					filename: 'main.js'
					path: path.resolve __dirname, 'dist'
				target: 'electron-main'
				externals: [ nodeExternals() ]
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
				mode: 'development'
				entry: './src/electron-app/renderer/index.coffee'
				output:
					filename: 'renderer.js'
					path: path.join __dirname, 'dist', 'renderer'
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

			server:
				mode: 'development'
				entry: './src/electron-app/server/express.coffee'
				output:
					filename: 'express.js'
					path: path.resolve __dirname, 'dist'
				target: 'node'
				externals: [ nodeExternals() ]
				node:
					__dirname: false
					__filename: false
				module:
					rules: [
						test: /\.coffee$/
						use: [ 'coffee-loader' ]
					]

			public:
				mode: 'development'
				entry: './src/electron-app/client/main.coffee'
				output:
					filename: 'main.js'
					path: path.resolve __dirname, 'dist', 'public'
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
				externals: [ /^socket$/ ]
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
			electron:
				command: 'npx electron dist'

		# electron:
		# 	options:
		# 		'appBundleId': packageInfo.applicationId
		# 		name: packageInfo.displayName
		# 		dir: 'pkg'
		# 		out: 'dist'
		# 		electronVersion: '<%= electronVersion %>' # use same version as during dev.
		# 		appVersion: packageInfo.version
		# 		asar: true
		# 		overwrite: true
		# 		icon: 'images/icon'
		# 		prune: true
		# 	osx:
		# 		options:
		# 			platform: 'darwin'
		# 			arch: 'x64'


	grunt.registerTask 'elserve', [
		'webpack:elMain'
		'webpack:elRenderer'
		'webpack:server'
		'webpack:public'
		'exec:electron'
	]
