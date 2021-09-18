require_relative '../../../puppet_x/ploperations/consul_data/common'

# Set, update, or delete a key in Consul
Puppet::Functions.create_function(:'consul_data::set_key') do
  # @summary Delete a key in Consul
  #
  # Delete a key in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to delete
  # @param value `undef` is the only valid value here
  #
  # @return Nothing is returned from this function
  dispatch :delete_key do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :key
    required_param 'Undef', :value
  end

  # @summary Update a key to a string value in Consul
  #
  # Update a key to a string value in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to update
  # @param value The string that you wish to have set as the value for the key
  #
  # @return Nothing is returned from this function
  dispatch :set_key_as_string do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :key
    required_param 'String[1]', :value
  end

  # @summary Update a key to a json value in Consul
  #
  # Update a key to a json value in Consul
  #
  # @param consul_url The full url including port for querying Consul
  # @param key The key you wish to update
  # @param value The array or hash that you wish to be stored in Consul as JSON
  #
  # @return Nothing is returned from this function
  dispatch :set_key_as_json do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :key
    required_param 'Variant[Hash, Array[Hash]]', :value
  end

  def delete_key(consul_url, key, _value)
    uri = PuppetX::Ploperations::ConsulData::Common.parse_consul_url(consul_url)
    use_ssl = uri.scheme == 'https'
    connection = Puppet::Network::HttpPool.http_instance(uri.host, uri.port, use_ssl)
    action = 'deleting'

    consul_response = connection.delete("/v1/kv/#{key}")

    process_response(uri, key, consul_response, action)
  end

  def set_key_as_string(consul_url, key, value)
    uri = PuppetX::Ploperations::ConsulData::Common.parse_consul_url(consul_url)
    use_ssl = uri.scheme == 'https'
    connection = Puppet::Network::HttpPool.http_instance(uri.host, uri.port, use_ssl)
    action = 'setting'

    consul_response = connection.put("/v1/kv/#{key}", value, 'Content-Type' => 'application/octet-stream')

    process_response(uri, key, consul_response, action)
  end

  def set_key_as_json(consul_url, key, value)
    uri = PuppetX::Ploperations::ConsulData::Common.parse_consul_url(consul_url)
    use_ssl = uri.scheme == 'https'
    connection = Puppet::Network::HttpPool.http_instance(uri.host, uri.port, use_ssl)

    consul_response = connection.put("/v1/kv/#{key}", value.to_json, 'Content-Type' => 'application/octet-stream')

    process_response(uri, key, consul_response, 'setting')
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
