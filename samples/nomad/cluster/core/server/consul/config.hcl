data_dir = "{{ key "consul/core/data_dir" }}"

bind_addr   = "{{ `{{ GetDefaultInterfaces | attr \"address\" }}` }}"
client_addr = "0.0.0.0"

server     = true
retry_join = [ {{ key "consul/servers/addresses" }} ]

encrypt = "{{ key "consul/gossip/key" }}"

tls {
  defaults {
    verify_incoming = true
    verify_outgoing = true

    {{ $ca_file_path := key "consul/core/config_dir" | printf "%s/tls/ca-cert.pem" }}
    {{ key "consul/tls/ca_cert" | writeToFile $ca_file_path  "" "" "0644" }}
    ca_file = "{{ $ca_file_path }}"

    {{ $cert_file_path := key "consul/core/config_dir" | printf "%s/tls/nomad-cert.pem" }}
    {{ key "consul/tls/server_cert" | writeToFile $cert_file_path "" "" "0600" }}
    cert_file = "{{ $cert_file_path }}"

    {{ $key_file_path := key "consul/core/config_dir" | printf "%s/tls/nomad-key.pem" }}
    {{ key "consul/tls/server_key" | writeToFile $key_file_path "" "" "0600" }}
    key_file = "{{ $key_file_path }}"
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
  allow_tls = true
}

ports {
  grpc = 8502
  grpc_tls = 8503
}

connect {
  enabled = true
}

ui_config {
  enabled = true
}
