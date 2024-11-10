job "echo" {
  type = "service"

  group "server" {
    count = 1

    network {
      port "server-http" {
        to = 5678
      }
    }

    service {
      name     = "echo-server"
      port     = "server-http"
    }

    task "server" {
      driver = "docker"

      config {
        image = "ghcr.io/gusztavvargadr/general-nomad-jobs-echo-server:latest"
        ports = ["server-http"]
        args = [
          "-text",
          "Hello, World from ${NOMAD_ADDR_server_http}!"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
