require_relative '../../../puppet_x/ploperations/consul_data/common'

# Querys for nodes providing a given service
Puppet::Functions.create_function(:'consul_data::get_service_nodes') do
  dispatch :get_service_nodes do
    required_param 'String[1]', :consul_url
    required_param 'String[1]', :service
  end

  # @summary Querys for nodes providing a given service
  #
  # Querys for nodes providing a given service
  #
  # @param consul_url The full url including port for querying Consul
  # @param service The service you want to get a list of nodes for
  # @return A hash representing the JSON response from Consul
  def get_service_nodes(consul_url, service)
    uri = PuppetX::Ploperations::ConsulData::Common.parse_consul_url(consul_url)
    use_ssl = uri.scheme == 'https'
    connection = Puppet::Network::HttpPool.http_instance(uri.host, uri.port, use_ssl)

    consul_response = connection.get("/v1/catalog/service/#{service}")
    unless consul_response.is_a?(Net::HTTPOK)
      message = "Received #{consul_response.code} response code from Consul at #{uri.host} for service #{service}"
      raise Puppet::Error, PuppetX::Ploperations::ConsulData::Common.append_api_errors(message, consul_response)
    end

    begin
      JSON.parse(consul_response.body)
    rescue StandardError
      raise Puppet::Error, 'Error parsing json from Consul response'
    end
  end
end
