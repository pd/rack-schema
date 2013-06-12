require 'spec_helper'

module SpecHelpers

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

end

module EchoApp
  def self.call(env)
    [env['echo.status'], env['echo.headers'], env['echo.body']]
  end
end

describe Rack::Schema do
  include SpecHelpers
  Invalid = Class.new(StandardError)

  def app
    Rack::Builder.new do
      use Rack::Schema do |errors, env, (status, headers, body)|
        raise Invalid if errors.any?
        headers['X-Schema'] = 'valid'
        [status, headers, body]
      end

      run EchoApp
    end
  end

  let(:headers) do
    { 'Content-Type' => 'application/json' }
  end

  def echo(headers, body, status = 200)
    env = {
      'echo.body' => body.to_json,
      'echo.headers' => headers,
      'echo.status' => status
    }
    get '/', {}, env
  end

  def assert_valid!
    expect(last_response.headers['X-Schema']).to eq('valid')
  end

  def expect_invalid(&block)
    expect(&block).to raise_error(Invalid)
  end

  context 'validate entire body' do
    before do
      headers['Link'] = described_by schema_uri('object')
    end

    specify 'pass' do
      echo headers, {}
      assert_valid!
    end

    specify 'fail by type' do
      expect_invalid { echo headers, 'a string' }
      expect_invalid { echo headers, [{}, {}] }
    end
  end

  context 'validate at anchor' do
    before do
      headers['Link'] = described_by schema_uri('widget'), '#/widget'
    end

    specify 'pass at anchor' do
      echo headers, { 'widget' => { 'name' => 'foo' } }
      assert_valid!
    end

    specify 'fail; object was at root instead of anchor' do
      expect_invalid do
        echo headers, { 'name' => 'foo' }
      end
    end

    specify 'fail; no such anchor' do
      expect_invalid do
        echo headers, { 'Widget' => { 'name' => 'foo' } }
      end
    end

    specify 'fail; anchor pointed to collection' do
      expect_invalid do
        echo headers, { 'widget' => [{'name' => 'foo'}, {'name' => 'bar'}] }
      end
    end
  end

  ['#', '#/'].each do |anchor|
    context "validate at anchor #{anchor.inspect}" do
      before do
        headers['Link'] = described_by schema_uri('widget'), anchor
      end

      specify 'pass' do
        echo headers, { 'name' => 'foo' }
        assert_valid!
      end

      specify 'fail' do
        expect_invalid do
          echo headers, { 'name' => true }
        end

        expect_invalid do
          echo headers, { 'widget' => { 'name' => 'foo' } }
        end
      end
    end
  end

  context 'validate collection' do
    before do
      headers['Link'] = described_by schema_uri('widget'), nil, :collection
    end

    specify 'pass' do
      echo headers, [{'name' => 'foo'}, {'name' => 'bar'}]
      assert_valid!
    end

    specify 'pass; empty array' do
      echo headers, []
      assert_valid!
    end

    specify 'fail; not an array' do
      expect_invalid do
        echo headers, {'name' => 'foo'}
      end
    end

    specify 'fail; invalid entry' do
      expect_invalid do
        echo headers, [{'name' => 'foo'}, {'invalid' => true}]
      end
    end
  end

  context 'validate collection at anchor' do
    before do
      headers['Link'] = described_by schema_uri('widget'), '#/widgets', :collection
    end

    specify 'pass' do
      echo headers, { 'widgets' => [{'name' => 'foo'}, {'name' => 'bar'}] }
      assert_valid!
    end

    specify 'pass; empty array' do
      echo headers, { 'widgets' => [] }
      assert_valid!
    end

    specify 'fail; no such anchor' do
      expect_invalid do
        echo headers, { 'Widgets' => [{'name' => 'foo'}] }
      end
    end

    specify 'fail; invalid entries' do
      expect_invalid do
        echo headers, { 'widgets' => [{'bogus' => 'object'}] }
      end
    end
  end

  context 'multiple schemas' do
    before do
      headers['Link'] = [described_by(schema_uri('response'), '#'),
                         described_by(schema_uri('widget'),   '#/widgets', :collection),
                         described_by(schema_uri('auction'),  '#/auction')].join(', ')
    end

    let(:body) do
      { 'links' => [{'rel' => 'self'}],
        'widgets' => [{'name' => 'foo'}],
        'auction' => {'bids' => 10, 'price' => 100}
      }
    end

    specify 'pass all' do
      echo headers, body
      assert_valid!
    end

    specify 'fail all' do
      expect_invalid do
        echo headers, {}
      end

      expect_invalid do
        echo headers, {'links' => 'oops', 'widgets' => ['so', 'wrong'], 'auction' => nil}
      end
    end

    specify 'fail one' do
      body['links'] = []
      expect_invalid do
        echo headers, body
      end
    end
  end
end
