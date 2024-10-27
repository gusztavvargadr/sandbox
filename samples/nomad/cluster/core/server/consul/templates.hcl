consul {
  retry {
    enabled = false
  }
}

template {
  source = "./config.hcl"
  destination = "/etc/consul.d/consul.hcl"
  perms = "0600"
}
