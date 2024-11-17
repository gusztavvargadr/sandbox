vault {
  renew_token = false

  retry {
    enabled = false
  }
}

template {
  source = "./env.sh.template"
  destination = "./artifacts/env.sh"
  perms = 0600
}
