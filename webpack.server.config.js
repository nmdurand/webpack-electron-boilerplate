const path = require('path');
const nodeExternals = require('webpack-node-externals');

module.exports = {
	mode: 'development',
	entry: './src/electron-app/server/express.coffee',
	output: {
		filename: 'express.js',
		path: path.resolve(__dirname, 'dist', 'server')
	},
	target: 'node',
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
