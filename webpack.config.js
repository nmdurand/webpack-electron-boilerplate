const mainConfig = require('./webpack.main.config');
const rendererConfig = require('./webpack.renderer.config');
// const serverConfig = require('./webpack.server.config');
const publicConfig = require('./webpack.public.config');

const config = [ mainConfig, rendererConfig, publicConfig ];

module.exports = config
