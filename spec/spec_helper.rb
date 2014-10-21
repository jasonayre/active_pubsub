require 'rubygems'
require 'bundler'
require 'simplecov'
require 'pry'
require 'active_pubsub'

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.before(:suite) do
    ::ActivePubsub.start_subscribers
  end
end

Bundler.require(:default, :development, :test)

::Dir["#{::File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f }
