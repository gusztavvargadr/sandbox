terraform {
  required_version = "~> 1.8"

  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.21"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.2"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "consul" {
    path = "gusztavvargadr-general.letsencrypt-core/terraform/state"
    gzip = true
  }
}

provider "acme" {
  server_url = local.acme.server
}

provider "vault" {
  skip_child_token = true
}
