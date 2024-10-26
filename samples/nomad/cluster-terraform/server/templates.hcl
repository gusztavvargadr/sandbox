vault {
  renew_token = false

  retry {
    enabled = false
  }
}

template {
  source = "./config.hcl"
  destination = "./artifacts/config/nomad.hcl"
}
