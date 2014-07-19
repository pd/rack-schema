# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/schema/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-schema"
  spec.version       = Rack::Schema::VERSION
  spec.authors       = ["Kyle Hargraves"]
  spec.email         = ["pd@krh.me"]
  spec.description   = %q{Validate rack responses against schema named in the Link header}
  spec.summary       = %q{Allows you to strictly validate each of your application's API responses against a declared JSON schema.}
  spec.homepage      = "http://github.com/pd/rack-schema"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "~> 1.0"
  spec.add_dependency "multi_json",  "~> 1.0"
  spec.add_dependency "json-schema", "~> 2.0"
  spec.add_dependency "link_header", "~> 0.0.8"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "json", "> 0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "simplecov", "~> 0.9"
  spec.add_development_dependency "coveralls", "> 0"
end
