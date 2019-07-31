const path = require('path');

module.exports = {
	mode: 'development',
	entry: './src/electron-app/main.coffee',
	output: {
		filename: 'main.js',
		path: path.resolve(__dirname, 'dist')
	},
	target: 'electron-main',
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
