require 'spec_helper'

describe 'consul_data::get_service_nodes' do
  let(:function) { subject }

  let(:response_body) do
    # rubocop:disable Metrics/LineLength
    '[{"ID":"0b327e89-6ec5-b074-7812-e5d402dce9e6","Node":"consul-app-dev-1.doesnotexist","Address":"10.0.0.101","Datacenter":"ops","TaggedAddresses":{"lan":"10.0.0.101","wan":"10.0.0.101"},"NodeMeta":{"consul-network-segment":""},"ServiceID":"consul","ServiceName":"consul","ServiceTags":[],"ServiceAddress":"","ServicePort":8300,"ServiceEnableTagOverride":false,"CreateIndex":3129490,"ModifyIndex":3129490},{"ID":"6153178c-0a76-8933-b1dc-03579912c0dd","Node":"consul-app-dev-2.doesnotexist","Address":"10.0.0.102","Datacenter":"ops","TaggedAddresses":{"lan":"10.0.0.102","wan":"10.0.0.102"},"NodeMeta":{"consul-network-segment":""},"ServiceID":"consul","ServiceName":"consul","ServiceTags":[],"ServiceAddress":"","ServicePort":8300,"ServiceEnableTagOverride":false,"CreateIndex":3129490,"ModifyIndex":3129490},{"ID":"14d0d20f-d2a5-1436-e182-12b92f1444cb","Node":"consul-app-dev-3.doesnotexist","Address":"10.0.0.103","Datacenter":"ops","TaggedAddresses":{"lan":"10.0.0.103","wan":"10.0.0.103"},"NodeMeta":{"consul-network-segment":""},"ServiceID":"consul","ServiceName":"consul","ServiceTags":[],"ServiceAddress":"","ServicePort":8300,"ServiceEnableTagOverride":false,"CreateIndex":3129490,"ModifyIndex":3129490}]'
    # rubocop:enable Metrics/LineLength
  end

  it 'gets nodes running Consul' do
    connection = instance_double('Puppet::Network::HTTP::Connection', address: 'consul-app-dev-1.doesnotexist')
    expect(Puppet::Network::HttpPool).to receive(:http_instance).and_return(connection)

    consul_response = Net::HTTPOK.new('1.1', 200, '')
    expect(consul_response).to receive(:body).and_return(response_body)
    expect(connection)
      .to receive(:get)
      .with('/v1/catalog/service/consul')
      .and_return(consul_response)

    result = function.execute('https://consul-app-dev-1.doesnotexist:8500', 'consul')
    expect(result).to include(a_kind_of(Hash))
    expect(result[0]).to include('Address' => '10.0.0.101')
    expect(result[2]).to include('Node' => 'consul-app-dev-3.doesnotexist')
  end
end
