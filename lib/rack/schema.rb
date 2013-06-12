require "rack/schema/version"
require "json-schema"
require "link_header"

module Rack
  class Schema
    ValidationError = Class.new(StandardError)

    def initialize(app, options = {}, &handler)
      @app = app

      @handler   = handler
      @handler ||= proc { |errors, env, (status, headers, body)|
        raise ValidationError.new({ errors: errors, body: body }) if errors.any?
      }

      @options = {
        cache_schemas:    true,
        validate_schemas: true,
        swallow_links:    false
      }.merge(options)

      JSON::Validator.cache_schemas = @options[:cache_schemas]
    end

    def call(env)
      status, headers, body = @app.call(env)

      links  = collect_schemas headers['Link']
      errors = links.reduce [] do |acc, link|
        json = at_anchor(body, link.attrs['anchor'])
        errs = validate(link.href, json, link.attrs.key?('collection'))
        acc.push [link.to_s, errs] if errs.any?
        acc
      end

      response = [status, headers, body]
      @handler.call(errors, env, response) || response
    end

    private

    def at_anchor(body, anchor)
      return body if anchor.nil? || anchor == '#' || anchor == '#/'
      json = JSON.parse(body)

      fragments = anchor.sub(/\A#\//, '').split('/')
      fragments.reduce JSON.parse(body) do |value, fragment|
        case value
        when Hash  then value.fetch(fragment, nil)
        when Array then value.fetch(fragment.to_i, nil)
        end
      end
    end

    def validate(uri, json, list = false)
      JSON::Validator.fully_validate uri, json, {
        validate_schemas: @options[:validate_schemas],
        list: list
      }
    end

    def collect_schemas(header)
      LinkHeader.parse(header).links.select do |link|
        link.attrs['rel'] == 'describedby'
      end
    end
  end
end
