require 'spec_helper'

describe Rack::Schema do
  context 'default handler' do
    def app
      Rack::Builder.new do
        use Rack::Schema
        run SpecHelpers::EchoApp
      end
    end

    it 'raises Rack::Schema::ValidationError if there were errors' do
      headers['Link'] = described_by schema_uri('widget')
      expect {
        echo headers, {}
      }.to raise_error(Rack::Schema::ValidationError)
    end

    it 'otherwise does not alter the response' do
      headers['Link'] = described_by schema_uri('widget')
      echo headers, {'name' => 'foo'}

      expect(last_response.headers).to have_key('Link')
      expect(last_response.body).to eql({'name' => 'foo'}.to_json)
    end
  end

  context 'swallow_links: true' do
    it 'removes matching links from the Link header'
    it 'removes the Link header if empty'
  end

  context 'validate_schemas: false' do
    it 'tells JSON::Validator not to validate the schema, too'
  end
end
