const path = require('path');
const nodeExternals = require('webpack-node-externals');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = {
	mode: 'development',
	entry: './src/electron-app/main.coffee',
	output: {
		filename: 'main.js',
		path: path.resolve(__dirname, 'dist')
	},
	target: 'electron-main',
	externals: [nodeExternals()],
	node: {
		__dirname: false,
		__filename: false
	},
	module: {
		rules: [
			{
				test: /\.coffee$/,
			 	loader: 'coffee-loader'
			}
		]
	},
	plugins:[
		new CopyPlugin([
			{
				from: './package.json',
				to: './package.json'
			}
		])
	]
};
