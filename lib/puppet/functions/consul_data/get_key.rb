require_relative '../../../puppet_x/ploperations/consul_data/common'
require_relative '../../../puppet_x/ploperations/consul_data/httpconnection'

# Get the value of a key from Consul
Puppet::Functions.create_function(:'consul_data::get_key') do
  # @summary Get the value of a key from Consul
  #
  # Get the value of a key from Consul
  #
  # @example Get the string stored in the key 'foo'
  #   consul_data::get_key('https://consul-app.example.com:8500', 'foo')
  #
  # @example Get a hash of the JSON stored in the key 'foo'
  #   consul_data::get_key('https://consul-app.example.com:8500', 'foo', hash)
  #
  # @example Get the JSON stored in the key 'foo'
  #   consul_data::get_key('https://consul-app.example.com:8500', 'foo', json)
  #
  # @example Get the formatted version of the JSON stored in the key 'foo'
  #   consul_data::get_key('https://consul-app.example.com:8500', 'foo', json_pretty)
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to query for
  # @param key_return_format
  #   The format in which to return the value of the key key.
  #   Defaults to 'string' but may also be 'hash', json', or 'json_pretty'.
  #   All options other than 'string' assume the data is stored in JSON format.
  # @return [Hash] If key_return_format is 'hash' the JSON stored in the key is converted to a Puppet Hash
  # @return [String] If key_return_format is 'json' the JSON stored in the key is returned as a single-line string
  # @return [String] If key_return_format is 'json_pretty' the JSON stored in the key is returned as a multi-line string with standard indentations
  # @retrun [String] If key_return_format is ommitted or 'string' the raw string stored in the key is returned
  dispatch :get_key do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :key
    optional_param 'Enum[hash, json, json_pretty, string]', :key_return_format
    return_type 'Variant[Hash, String,]'
  end

  # @summary Get the value of a key from Consul
  #
  # Get the value of a key from Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to query for
  # @param key_return_format
  #   The format in which to return the value of the key key.
  #   Defaults to 'string' but may also be 'hash', json', or 'json_pretty'.
  #   All options other than 'string' assume the data is stored in JSON format.
  # @return the value of the key in the specified format
  def get_key(consul_url, key, key_return_format = 'string')
    http_connection = PuppetX::Ploperations::ConsulData::HTTPConnection.new(consul_url)
    consul_response = http_connection.connection.get("/v1/kv/#{key}?raw=true")
    unless consul_response.is_a?(Net::HTTPOK)
      message = "Received #{consul_response.code} response code from Consul at #{http_connection.uri.host} for key #{key}"
      raise Puppet::Error, PuppetX::Ploperations::ConsulData::Common.append_api_errors(message, consul_response)
    end

    begin
      case key_return_format
      when 'hash'
        JSON.parse(consul_response.body)
      when 'json'
        data = JSON.parse(consul_response.body)
        data.to_json
      when 'json_pretty'
        data = JSON.parse(consul_response.body)
        JSON.pretty_generate(data)
      else
        consul_response.body
      end
    rescue StandardError
      raise Puppet::Error, 'Error parsing json from Consul response'
    end
  end
end
