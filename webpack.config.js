const path = require('path');
// const exec = require('child_process').exec;

module.exports = {
	mode: 'development',
	entry: './src/scripts/index.coffee',
	output: {
		filename: 'bundle.js',
		path: path.resolve(__dirname, 'dist')
	},
	target: 'electron-main',
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
	}
	// plugins:[
	// 	{
	// 		apply: (compiler) => {
	// 			compiler.hooks.afterEmit.tap('AfterEmitPlugin', (compilation) => {
	// 				exec('npx electron dist/', (err, stdout, stderr) => {
	// 					if (stdout) process.stdout.write(stdout);
	// 					if (stderr) process.stderr.write(stderr);
	// 				});
	// 			});
	// 		}
	// 	}
	// ]
};
