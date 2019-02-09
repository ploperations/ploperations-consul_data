
# Use data from Consul in Puppet code

![](https://img.shields.io/puppetforge/pdk-version/ploperations/consul_data.svg?style=popout)
![](https://img.shields.io/puppetforge/v/ploperations/consul_data.svg?style=popout)
![](https://img.shields.io/puppetforge/dt/ploperations/consul_data.svg?style=popout)

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage & Reference](#usage--reference)
   - [Query the Consul agent on a node directly](#query-the-consul-agent-on-a-node-directly)
4. [Development](#development)

## Description

`consul_data` provides a simple way to interact with Consul. You can get or set
key/value pairs and query for the nodes backing a service. You can also wrap
function calls in `Deferred()` to query the local Consul agent on a node
instead of reaching out to your Consul cluster from the Puppet master.

## Setup

All that's required to use this module is it being added to your Puppetfile
and pluginsync being enabled.

## Usage & Reference

_Note: additional documentation is in [REFERENCE.md](REFERENCE.md)_
_The docs below are provided to supplement what `puppet-strings`_
_generates as it doesn't pick up all the tags in the source code._

**`consul_data::get_key($consul_url, $key, $key_return_format)`**

Get the value of a key from Consul

- `consul_url`: The full url including port for querying Consul
- `key`: The key you wish to query for
- `key_return_format`: The format in which to return the value of the key key.
   - Defaults to `string` but may also be `hash`, `json`, or `json_pretty`.
   - All options other than `string` assume the data is stored in JSON format.

This will return the value of the key in the specified format.

**`consul_data::get_service_nodes($consul_url, $service)`**

Querys for nodes providing a given service

- `consul_url`: The full url including port for querying Consul
- `service`: The service you want to get a list of nodes for

This will return a `Hash` representing the JSON response from Consul.

Example: Get a list of nodes running Consul and their IP addresses

```puppet
$data = consul_data::get_service_nodes('https://consul-app.example.com:8500', 'consul')
$data.each |$consul_node| {
  notify { "${consul_node['Node']} is at ${consul_node['Address']}": }
}
```

**`consul_data::set_key($consul_url, $key, $value)`**

Set, update, or delete a key in Consul

- `consul_url`: The full url including port for querying Consul
- `key`: The key you wish to set, update, or delete
- `value`:
  - if set to `undef` the specified key will be deleted
  - if set to a string the key will be updated to contain that string
  - if set to a hash or and array of hashes the key will be updated to contain
    the JSON representation of that value passed in.

### Query the Consul agent on a node directly

You can take advantage of `Deferred()` to interact with the Consul agent on a
node directly. For example:

```puppet
$some_value_from_consul = Deferred('consul_data::get_key', [$consul_url, 'foo', 'json_pretty'])

file { $some_config_file:
  ensure  => file,
  content => $some_value_from_consul,
}
```

You can also use a templated file to benefit from querying the node's agent:

```puppet
$variables = {
  'nodes_hash' => Deferred('consul_data::get_service_nodes',[
    'https://consul-app.example.com:8500',
    'my-service'
  ]),
}

# use inline_epp(), and file() to compile the template source into the catalog
file { '/etc/my-service.conf':
  ensure  => file,
  content => Deferred('inline_epp', [
    file('mymodule/my-service.conf.epp'),
    $variables
  ]),
}
```

_Note_: the template resides at `mymodule/files/my-service.conf.epp` as opposed
to in the `templates` directory.

In this example, you could have a template that used values found in the hash
`nodes_hash` such as the node names and their IP addresses.

## Development

Pull requests are welcome!
