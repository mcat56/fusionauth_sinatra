require './app'
require 'bundler'
Bundler.require
require File.expand_path('../config/environment', __FILE__)

run Sinatra::Application