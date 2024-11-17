job "dotnet" {
  type = "service"

  group "api" {
    count = 1

    network {
      port "api-http" {
        to = 8080
      }
    }

    service {
      name     = "dotnet-api"
      port     = "api-http"
    }

    task "api" {
      driver = "docker"

      config {
        image = "ghcr.io/gusztavvargadr/general-nomad-jobs-dotnet-api:latest"
        ports = ["api-http"]
      }

      env {
        ASPNETCORE_ENVIRONMENT = "Development"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
