const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const path = require('path');
const webpack = require('webpack');

module.exports = {
	mode: 'development',
	entry: './src/electron-app/client/main.coffee',
	output: {
		filename: 'main.js',
		path: path.resolve(__dirname, 'dist', 'public')
	},
	target: 'electron-renderer',
	devtool: 'inline-source-map',
	module: {
		rules: [
			{
				test: /\.css$/,
				use: [
					'style-loader',
					'css-loader'
				]
			},
			{
				test: /\.s(c|a)ss$/,
				use: [
					'style-loader',
					'css-loader',
					'sass-loader'
				]
			},
			{
				test: /\.coffee$/,
				use: [ 'coffee-loader' ]
			},
			{
				test: /\.hbs$/,
				use: [ 'handlebars-loader' ]
			},
			{
				test: /\.(woff(2)?|ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
				use: [
					{
						loader: 'file-loader',
						options: {
							name: '[name].[ext]',
							outputPath: 'fonts/'
						}
					}
				]
			},
			{
				test: /\.(png|svg|jpg|gif)$/,
				use: [
					{
						loader: 'file-loader',
						options: {
							outputPath: 'images/'
						}
					}
				]
			}
		]
	},
	externals: [
		/^socket$/
	],
	plugins: [
		new HtmlWebpackPlugin({
			template: "./src/electron-app/client/index.html"
		}),
		new CopyPlugin([
			{
				from: './src/electron-app/client/images/favicon.ico',
				to: './images/favicon.ico'
			}
		]),
		new webpack.ProvidePlugin({
			$: "jquery",
			jQuery: "jquery"
		})
	]
};
