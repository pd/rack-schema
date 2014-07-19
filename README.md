# Rack::Schema

[![Gem Version](https://badge.fury.io/rb/rack-schema.svg)](http://badge.fury.io/rb/rack-schema)
[![Build Status](https://travis-ci.org/pd/rack-schema.svg?branch=master)](https://travis-ci.org/pd/rack-schema)
[![Dependency Status](https://gemnasium.com/pd/rack-schema.svg)](https://gemnasium.com/pd/rack-schema)
[![Code Climate](https://codeclimate.com/github/pd/rack-schema.png)](https://codeclimate.com/github/pd/rack-schema)
[![Coverage Status](https://img.shields.io/coveralls/pd/rack-schema.svg)](https://coveralls.io/r/pd/rack-schema?branch=master)

Validate your application's responses against [JSON Schemas][json-schema].

## Installation

Add this line to your application's Gemfile:

    gem 'rack-schema'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-schema

## Usage
Mount `Rack::Schema` as middleware in one of the normal manners:

~~~~ruby
# using config.ru:
use Rack::Schema
run MyApp

# or application.rb:
config.middleware.use Rack::Schema
~~~~

Your application can now return an HTTP [Link header][link-header]
with a `rel` attribute value of `describedby`, and `Rack::Schema` will
automatically attempt to validate responses against the specified
schema (using the [json-schema gem][hoxworth]). An example `Link`
header:

    Link: <http://example.com/schemas/response>; rel="describedby"

If your schema applies only to a part of the JSON response, you can
use the `anchor` attribute to specify a JSON path to the relevant value:

    Link: <http://example.com/schemas/widget>; rel="describedby"; anchor="#/widget"

This is actually a mis-use of the `anchor` attribute, which would
typically be used to specify an anchor within the *linked* document,
rather than the document being described. JSON schemas already support
the use of the hash fragment on its URI, however, so I've
re-appropriated it. Suggestions for a more compliant tactic are
welcome.

If your response is actually a collection of objects that should all
validate against the same schema, use the `collection` attribute:

    # Assert that the response is an array, and each object within it is a valid widget.
    Link: <http://example.com/schemas/widget>; rel="describedby"; collection="collection"

    # Assert that the object at '#/widgets' is an array, and each object within it is a valid widget.
    Link: <http://example.com/schemas/widget>; rel="describedby"; anchor="#/widgets"; collection="collection"

If the `Link` header contains multiple applicable links, they will
all be used to validate the response:

    # Assert that '#/teams' is an array of valid teams, and '#/score' is a valid score.
    Link: <http://example.com/schemas/team>; rel="describedby"; anchor="#/teams"; collection="collection",
          <http://example.com/schemas/score>; rel="describedby"; anchor="#/score"

## Configuration

### Validate Schemas
By default, `rack-schema` will also instruct the validator to validate
your schema itself *as* a schema. To disable that behavior:

~~~~ruby
use Rack::Schema, validate_schemas: false
~~~~

### Swallow Links
If you are running the `rack-schema` response validator in a
production environment -- which you probably *shouldn't* be doing --
and you don't want to actually expose the `describedby` link header
entries to the world, you can tell `rack-schema` to remove them from
the responses after using them:

~~~~ruby
use Rack::Schema, swallow_links: true
~~~~

With `swallow_links` on, only the *describedby* links will be removed;
your pagination or similar links will not be disturbed.

### Error Handler
By default, `rack-schema` will raise a `ValidationError` if it encounters
any errors in your response JSON. If that's not your bag, you can define
a different error handler by providing a block:

~~~ruby
use Rack::Schema do |errors, env, (status, headers, body)|
  # Preferably, use a less useless error message.
  my_logger.warn("JSON response did not match schema!")
end
~~~


## Potential Features?

1. Validate incoming JSON bodies, but I just don't need that right now.
   And it's unclear how we'd determine what schemas to use, or what we'd
   do with the errors.

## See Also

1. [HTTP Link Header][link-header]
2. [json-schema gem][hoxworth]

[json-schema]: http://json-schema.org
[link-header]: http://tools.ietf.org/html/rfc5988#section-5
[hoxworth]: https://github.com/hoxworth/json-schema
