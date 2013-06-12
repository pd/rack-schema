require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'rack'
require 'rspec'
require 'rack/test'
require 'rack/schema'
require 'pry'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
