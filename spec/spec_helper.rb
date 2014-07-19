require 'bundler/setup'

require 'simplecov'
require 'coveralls'

SimpleCov.formatters = [
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
]

SimpleCov.start do
  add_filter "/spec/"
end

require 'rspec'
require 'rack/test'
require 'rack/schema'
require "json"
require 'pry'

module SpecHelpers
  def echo(headers, body, status = 200)
    env = {
      'echo.body' => MultiJson.dump(body),
      'echo.headers' => headers,
      'echo.status' => status
    }
    get '/', {}, env
  end

  def headers
    @headers ||= {
      'Content-Type' => 'application/json'
    }
  end

  def schema_uri(name)
    "file://#{schema_file(name)}"
  end

  def schema_file(name)
    File.expand_path("../schemas/#{name}.json", __FILE__)
  end

  def described_by(uri, anchor = nil, collection = nil)
    header = "<#{uri}>; rel=\"describedby\""
    header.concat "; anchor=\"#{anchor}\"" if anchor
    header.concat "; collection=\"collection\"" if collection
    header
  end

  module EchoApp
    def self.call(env)
      body = [env['echo.body']] # body should respond to :each
      [env['echo.status'], env['echo.headers'], body]
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include SpecHelpers
end
