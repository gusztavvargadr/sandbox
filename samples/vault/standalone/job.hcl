job "vault-standalone" {
  type = "service"

  group "server" {
    count = 1

    task "agent" {
      driver = "docker"

      template {
        data = <<EOH
disable_mlock = true

storage "file" {
  path = "/vault/file"
}

api_addr = "http://127.0.0.1:8200"

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
}

ui = true
EOH

        destination = "local/config/config.hcl"
      }

      config {
        image = "hashicorp/vault:1.16.2"

        volumes = [
          "local/config:/vault/config",
          "/opt/nomad/volumes/vault-server-agent-file:/vault/file",
          "/opt/nomad/volumes/vault-server-agent-logs:/vault/logs",
        ]

        network_mode = "host"

        args = [
          "server",
        ]
      }

      env = {
        SKIP_SETCAP = "true"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
