const { environment } = require('@rails/webpacker')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const webpack = require('webpack')

// Add an ProvidePlugin
// environment.plugins.provide used to be used, on some machines due to version difference this has to change to environment.plugins.prepend
// Having an incompatible version and line here will lead to errors such as unfound js packages (e.g jsgrid)
environment.plugins.prepend('Provide',  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    w2ui: 'w2ui',
    chart: 'chart',
    Chart: 'chart'
  })
)

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: "jquery/src/jquery",
  w2ui: "w2ui/w2ui",
  chart: "chart.js/dist/Chart"
}
module.exports = environment
