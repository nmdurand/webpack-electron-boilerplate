const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');

module.exports = {
	mode: 'development',
	entry: './src/electron-app/renderer/index.coffee',
	output: {
		filename: 'renderer.js',
		path: path.join(__dirname, 'dist', 'renderer')
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
	plugins: [new HtmlWebpackPlugin({
			template: "./src/electron-app/renderer/index.html"
		})
	]
};
