data_dir = "{{ with secret "/kv/nomad/core" }}{{ .Data.data.data_dir }}{{end}}"

bind_addr = "0.0.0.0"

server {
  enabled          = true
  encrypt          = "{{ with secret "/kv/nomad/gossip" }}{{ .Data.data.key }}{{end}}"
  bootstrap_expect = 1
}

tls {
  http = true
  rpc  = true

  {{ with secret "/kv/nomad/tls" }}{{ .Data.data.ca_cert | base64Decode | writeToFile "./artifacts/config/tls/ca-cert.pem" "" "" "0600" }}{{end}}
  ca_file   = "{{ with secret "/kv/nomad/core" }}{{ printf "%s/tls/ca-cert.pem" .Data.data.config_dir }}{{end}}"

  {{ with secret "/kv/nomad/tls" }}{{ .Data.data.server_cert | base64Decode | writeToFile "./artifacts/config/tls/nomad-cert.pem" "" "" "0600" }}{{end}}
  cert_file = "{{ with secret "/kv/nomad/core" }}{{ printf "%s/tls/nomad-cert.pem" .Data.data.config_dir }}{{end}}"

  {{ with secret "/kv/nomad/tls" }}{{ .Data.data.server_key | base64Decode | writeToFile "./artifacts/config/tls/nomad-key.pem" "" "" "0600" }}{{end}}
  key_file  = "{{ with secret "/kv/nomad/core" }}{{ printf "%s/tls/nomad-key.pem" .Data.data.config_dir }}{{end}}"
}

acl {
  enabled = true
}
