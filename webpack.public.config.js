const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');

module.exports = {
	mode: 'development',
	entry: './src/electron-app/public/index.coffee',
	output: {
		filename: 'index.js',
		path: path.resolve(__dirname, 'dist', 'public')
	},
	target: 'electron-renderer',
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
			}
		]
	},
	plugins: [new HtmlWebpackPlugin({
			template: "./src/electron-app/public/index.html"
		})
	]
};
