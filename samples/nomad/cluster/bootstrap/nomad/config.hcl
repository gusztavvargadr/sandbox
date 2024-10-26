data_dir = "{{ key "nomad/core/data_dir" }}"

bind_addr = "0.0.0.0"

addresses {
  http = "127.0.0.1"
}

advertise {
  http = "127.0.0.1"
}

server {
  enabled = true
  encrypt = "{{ key "nomad/gossip/key" }}"

  bootstrap_expect = 1
}

client {
  enabled = true

  # cpu_total_compute = 2000
}

tls {
  rpc  = true

  {{ $ca_file_path := key "nomad/core/config_dir" | printf "%s/tls/ca-cert.pem" }}
  {{ key "nomad/tls/ca_cert" | writeToFile $ca_file_path  "" "" "0644" }}
  ca_file = "{{ $ca_file_path }}"

  {{ $cert_file_path := key "nomad/core/config_dir" | printf "%s/tls/nomad-cert.pem" }}
  {{ key "nomad/tls/server_cert" | writeToFile $cert_file_path "" "" "0600" }}
  cert_file = "{{ $cert_file_path }}"

  {{ $key_file_path := key "nomad/core/config_dir" | printf "%s/tls/nomad-key.pem" }}
  {{ key "nomad/tls/server_key" | writeToFile $key_file_path "" "" "0600" }}
  key_file = "{{ $key_file_path }}"
}

limits {
  http_max_conns_per_client = 0
  rpc_max_conns_per_client  = 0
}

acl {
  enabled = true
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
