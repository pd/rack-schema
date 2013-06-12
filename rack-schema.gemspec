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
  spec.summary       = %q{Don't use this in prod kids.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "json-schema"
  spec.add_dependency "link_header"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
end
