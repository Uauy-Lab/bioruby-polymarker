/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require('jquery')
require('jquery-ui')
require('w2ui')
require('chart')
require('msa')
require('biojs-io-fasta')
require('jsgrid')
require("expose-loader?$!jquery");
require("expose-loader?jsgrid!jsgrid");
require("expose-loader?msa!msa");
require("expose-loader?fasta!biojs-io-fasta");

// console.log('Hello World from Webpacker')
