const publicConfig = require('./webpack.public.config');
const serverConfig = require('./webpack.server.config');

const config = [ publicConfig, serverConfig ];

module.exports = config
