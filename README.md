# Rack::Schema

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

Your application can now return an HTTP `Link` header with a `rel`
attribute value of `describedby`, and `Rack::Schema` will
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

    # Assert that the response is an array, and each object within it is a valid schema.
    Link: <http://example.com/schemas/widget>; rel="describedby"; collection="collection"

    # This works with anchors as well, of course:
    Link: <http://example.com/schemas/widget>; rel="describedby"; anchor="#/widgets"; collection="collection"

## Potential Features?

1. Validate incoming JSON bodies, but I just don't need that right now.
   And it's unclear how we'd determine what schemas to use.

## See Also

1. [HTTP Link Header][link-header]
2. [json-schema gem][hoxworth]

[json-schema]: http://json-schema.org
[link-header]: http://tools.ietf.org/html/rfc5988#section-5
[hoxworth]: https://github.com/hoxworth/json-schema
