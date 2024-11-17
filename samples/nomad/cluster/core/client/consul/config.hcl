data_dir = "{{ key "consul/core/data_dir" }}"

bind_addr   = "{{ `{{ GetDefaultInterfaces | attr \"address\" }}` }}"
client_addr = "127.0.0.1"

server     = false
retry_join = [ {{ key "consul/servers/addresses" }} ]

encrypt = "{{ key "consul/gossip/key" }}"

tls {
  defaults {
    verify_incoming = true
    verify_outgoing = true

    {{ $ca_file_path := key "consul/core/config_dir" | printf "%s/tls/ca-cert.pem" }}
    {{ key "consul/tls/ca_cert" | writeToFile $ca_file_path  "" "" "0644" }}
    ca_file = "{{ $ca_file_path }}"
  }

  internal_rpc {
    verify_server_hostname = true
  }
}

acl {
  enabled                  = true
  default_policy           = "deny"
  enable_token_persistence = true

  tokens {
    agent = "{{ key "consul/acl/agent_token_agent" }}"
    default = "{{ key "consul/acl/agent_token_default" }}"
  }
}

auto_encrypt {
  tls = true
}
