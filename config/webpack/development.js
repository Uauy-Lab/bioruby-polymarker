const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

// Add an ProvidePlugin
environment.plugins.set('Provide',  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    jqGrid: 'jqGrid',
  })
)

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: "jquery/src/jquery",
  jqGrid: "jqgrid/js/jquery.jqGrid.src",
}

module.exports = environment.toWebpackConfig()
