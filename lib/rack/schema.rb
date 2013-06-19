require "rack/schema/version"
require "json-schema"
require "link_header"
require "multi_json"

module Rack
  class Schema
    ValidationError = Class.new(StandardError)

    def initialize(app, options = {}, &handler)
      @app = app

      @handler   = handler
      @handler ||= proc { |errors, env, (status, headers, body)|
        json = ''
        body.each { |s| json.concat s }
        raise ValidationError.new({ errors: errors, body: json }) if errors.any?
      }

      @options = {
        validate_schemas: true,
        swallow_links:    false
      }.merge(options)
    end

    def call(env)
      status, headers, body = @app.call(env)

      link_header  = LinkHeader.parse(headers['Link'])
      schema_links = link_header.links.select do |link|
        link.attrs['rel'] == 'describedby'
      end

      errors = validate(body, schema_links)
      swallow(headers, link_header) if swallow_links?
      response = [status, headers, body]
      @handler.call(errors, env, response) || response
    end

    private

    def validate(body, schema_links)
      schema_links.each_with_object [] do |link, acc|
        json = at_anchor(body, link.attrs['anchor'])

        errs = JSON::Validator.fully_validate link.href, json, {
          validate_schemas: @options[:validate_schemas],
          list: link.attrs.key?('collection')
        }

        acc.push [link.to_s, errs] if errs.any?
      end
    end

    def swallow_links?
      @options[:swallow_links] == true
    end

    def swallow(headers, link_header)
      link_header.links.reject! { |link| link.attrs['rel'] == 'describedby' }
      if link_header.links.any?
        headers['Link'] = link_header.to_s
      else
        headers.delete 'Link'
      end
    end

    def at_anchor(body, anchor)
      flat = ''
      body.each { |s| flat.concat s }

      return flat if anchor.nil? || anchor == '#' || anchor == '#/'

      fragments = anchor.sub(/\A#\//, '').split('/')
      fragments.reduce MultiJson.load(flat) do |value, fragment|
        case value
        when Hash  then value.fetch(fragment, nil)
        when Array then value.fetch(fragment.to_i, nil)
        end
      end
    end
  end
end
