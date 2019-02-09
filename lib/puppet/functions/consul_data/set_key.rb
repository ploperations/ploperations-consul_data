require_relative '../../../puppet_x/ploperations/consul_data/common'
require_relative '../../../puppet_x/ploperations/consul_data/httpconnection'

# Set, update, or delete a key in Consul
Puppet::Functions.create_function(:'consul_data::set_key') do
  # @summary Delete a key in Consul
  #
  # Delete a key in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to delete
  # @param value `undef` is the only valid value here
  dispatch :delete_key do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :key
    required_param 'Undef', :value
    return_type 'Undef'
  end

  # @summary Update a key to a string value in Consul
  #
  # Update a key to a string value in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to update
  # @param value The string that you wish to have set as the value for the key
  dispatch :set_key_as_string do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :key
    required_param 'String[1]', :value
    return_type 'Undef'
  end

  # @summary Update a key to a json value in Consul
  #
  # Update a key to a json value in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to update
  # @param value The array or hash that you wish to be stored in Consul as JSON
  dispatch :set_key_as_json do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :key
    required_param 'Variant[Hash, Array[Hash]]', :value
    return_type 'Undef'
  end

  # @summary Delete a key in Consul
  #
  # Delete a key in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to delete
  # @param value `undef` is the only valid value here
  def delete_key(consul_url, key, _value)
    http_connection = PuppetX::Ploperations::ConsulData::HTTPConnection.new(consul_url)
    action = 'deleting'
    consul_response = http_connection.connection.delete("/v1/kv/#{key}")

    process_response(http_connection.uri, key, consul_response, action)
  end

  # @summary Update a key to a string value in Consul
  #
  # Update a key to a string value in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to update
  # @param value The string that you wish to have set as the value for the key
  def set_key_as_string(consul_url, key, value)
    http_connection = PuppetX::Ploperations::ConsulData::HTTPConnection.new(consul_url)
    action = 'setting'
    consul_response = http_connection.connection.put("/v1/kv/#{key}", value, 'Content-Type' => 'application/octet-stream')

    process_response(http_connection.uri, key, consul_response, action)
  end

  # @summary Update a key to a json value in Consul
  #
  # Update a key to a json value in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to update
  # @param value The array or hash that you wish to be stored in Consul as JSON
  def set_key_as_json(consul_url, key, value)
    http_connection = PuppetX::Ploperations::ConsulData::HTTPConnection.new(consul_url)
    consul_response = http_connection.connection.put("/v1/kv/#{key}", value.to_json, 'Content-Type' => 'application/octet-stream')

    process_response(http_connection.uri, key, consul_response, 'setting')
  end

  private

  # @summary Process the response from the api and raise any needed errors
  #
  # Process the response from the api and raise any needed errors
  # @param uri An object representing the url's parts
  # @param key The key you wish to update
  # @param consul_response the object representing the response from the Consul api
  # @param action The string representing the action that was taken (or attemted)
  def process_response(uri, key, consul_response, action)
    unless consul_response.is_a?(Net::HTTPOK)
      message = "Received #{consul_response.code} response code from Consul at #{uri.host} while #{action} key #{key}"
      raise Puppet::Error, PuppetX::Ploperations::ConsulData::Common.append_api_errors(message, consul_response)
    end

    begin
      response = consul_response.body
      unless response.eql? 'true'
        message = "Received a response of '#{response}' instead of 'true' when #{action} key #{key}"
        raise Puppet::Error, PuppetX::Ploperations::ConsulData::Common.append_api_errors(message, consul_response)
      end
    rescue StandardError
      raise Puppet::Error, "Error parsing json from Consul response. The raw response is '#{consul_response.body}'"
    end
  end
end
