require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'rack'
require 'rspec'
require 'rack/test'
require 'rack/schema'
require 'pry'

module SpecHelpers
  def echo(headers, body, status = 200)
    env = {
      'echo.body' => body.to_json,
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
      [env['echo.status'], env['echo.headers'], env['echo.body']]
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include SpecHelpers
end
