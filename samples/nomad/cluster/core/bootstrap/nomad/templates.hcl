consul {
  retry {
    enabled = false
  }
}

template {
  source = "./config.hcl"
  destination = "/etc/nomad.d/nomad.hcl"
  perms = "0600"
}
