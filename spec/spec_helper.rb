require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'rspec'
require 'rack/test'
require 'rack/schema'
require 'pry'

# `json' needs to be here because simplecov assumes that if
# ::JSON is defined, it means we have ruby's JSON loaded; otherwise,
# they use MultiJson. silly.
require "oj"
require "json"

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
