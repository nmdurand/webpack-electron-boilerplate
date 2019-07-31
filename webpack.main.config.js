const path = require('path');
const nodeExternals = require('webpack-node-externals');

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
				use: [ 'coffee-loader' ]
			}
		]
	}
};
