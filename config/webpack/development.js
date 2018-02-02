const { environment } = require('@rails/webpacker')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const webpack = require('webpack')

// Add an ProvidePlugin
environment.plugins.set('Provide',  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    w2ui: 'w2ui',
  })
)

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: "jquery/src/jquery",
  w2ui: "w2ui/w2ui",
}

module.exports = environment.toWebpackConfig()
