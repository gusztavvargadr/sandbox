# client {
#   cpu_total_compute = 2000
# }

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
