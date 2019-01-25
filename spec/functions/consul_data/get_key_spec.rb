require 'spec_helper'

describe 'consul_data::get_key' do
  let(:function) { subject }

  context 'as string' do
    let(:response_body) { 'bar' }

    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)
      expect(connection)
        .to receive(:get)
        .with('/v1/kv/foo?raw=true')
        .and_return(consul_response)

      result = function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo')
      expect(result).to eq('bar')
    end
  end

  context 'as hash' do
    let(:response_body) { '{"foo1":{"foo_sub_1":"bar_sub_1"},"foo2":"bar2"}' }

    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)
      expect(connection)
        .to receive(:get)
        .with('/v1/kv/foo?raw=true')
        .and_return(consul_response)

      result = function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo', 'hash')
      expect(result).to include('foo1' => { 'foo_sub_1' => 'bar_sub_1' })
    end
  end

  context 'as json' do
    let(:response_body) { '{"foo1":{"foo_sub_1":"bar_sub_1"},"foo2":"bar2"}' }

    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)
      expect(connection)
        .to receive(:get)
        .with('/v1/kv/foo?raw=true')
        .and_return(consul_response)

      result = function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo', 'json')
      expect(result).to eq('{"foo1":{"foo_sub_1":"bar_sub_1"},"foo2":"bar2"}')
    end
  end

  context 'as json_pretty' do
    let(:response_body) { '{"foo1":{"foo_sub_1":"bar_sub_1"},"foo2":"bar2"}' }

    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)
      expect(connection)
        .to receive(:get)
        .with('/v1/kv/foo?raw=true')
        .and_return(consul_response)

      result = function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo', 'json_pretty')
      pretty_result = <<~JSON.strip
        {
          "foo1": {
            "foo_sub_1": "bar_sub_1"
          },
          "foo2": "bar2"
        }
      JSON
      expect(result).to eq(pretty_result)
    end
  end
end
