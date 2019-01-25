require 'spec_helper'

describe 'consul_data::set_key' do
  let(:function) { subject }

  let(:response_body) { 'true' }

  context 'with value => undef' do
    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)

      expect(connection)
        .to receive(:delete)
        .with('/v1/kv/foo')
        .and_return(consul_response)

      function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo', nil)
    end
  end

  context 'with value => bar' do
    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)

      expect(connection)
        .to receive(:put)
        .with('/v1/kv/foo', 'bar', 'Content-Type' => 'application/octet-stream')
        .and_return(consul_response)

      function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo', 'bar')
    end
  end

  context 'with value => [{"foo" => "bar"}]' do
    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)

      # rubocop:disable Style/StringLiterals
      expect(connection)
        .to receive(:put)
        .with('/v1/kv/foo', "[{\"foo\" => \"bar\"}]", 'Content-Type' => 'application/octet-stream')
        .and_return(consul_response)
      # rubocop:enable Style/StringLiterals

      function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo', '[{"foo" => "bar"}]')
    end
  end

  context 'with value => {"foo" => "bar"}' do
    it do
      connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
      expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

      consul_response = Net::HTTPOK.new('1.1', 200, '')
      expect(consul_response).to receive(:body).and_return(response_body)

      # rubocop:disable Style/StringLiterals
      expect(connection)
        .to receive(:put)
        .with('/v1/kv/foo', "{\"foo\" => \"bar\"}", 'Content-Type' => 'application/octet-stream')
        .and_return(consul_response)
      # rubocop:enable Style/StringLiterals

      function.execute('https://consul-app-dev-1.doesnotexist:8500', 'foo', '{"foo" => "bar"}')
    end
  end
end
