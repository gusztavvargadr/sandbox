job "vault-development" {
  type = "service"

  group "server" {
    count = 1

    task "agent" {
      driver = "docker"

      config {
        image = "hashicorp/vault:1.16.2"

        network_mode = "host"

        args = [
          "server",
          "-dev",
          "-dev-root-token-id=root",
          "-dev-listen-address=127.0.0.1:8200",
        ]
      }

      env {
        SKIP_SETCAP = "true"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
