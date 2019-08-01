const mainConfig = require('./webpack.main.config');
const rendererConfig = require('./webpack.renderer.config');
const publicConfig = require('./webpack.public.config');
const serverConfig = require('./webpack.server.config');

const config = [mainConfig, rendererConfig, publicConfig, serverConfig];

module.exports = config
