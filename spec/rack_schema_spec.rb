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
      expect(last_response.body).to eql(MultiJson.dump({'name' => 'foo'}))
    end
  end

  context 'swallow_links: true' do
    def app
      Rack::Builder.new do
        use Rack::Schema, swallow_links: true
        run SpecHelpers::EchoApp
      end
    end

    it 'removes only rel=describedby Links' do
      headers['Link'] = [described_by(schema_uri('widget')),
                         '<http://another/link>; rel="next"'].join(", ")
      echo headers, { 'name' => 'foo' }

      expect(last_response.headers).to have_key('Link')
      expect(last_response.headers['Link']).to eql('<http://another/link>; rel="next"')
    end

    it 'removes the Link header if empty' do
      headers['Link'] = described_by schema_uri('widget')
      echo headers, { 'name' => 'foo' }
      expect(last_response.headers).not_to have_key('Link')
    end
  end
end
