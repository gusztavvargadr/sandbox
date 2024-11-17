terraform {
  required_version = "~> 1.8"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

variable "ssh_key" {
  type = object({
    algorithm = optional(string, "RSA")
  })
  default = {}
}

locals {
  ssh_key_options = var.ssh_key
}

resource "tls_private_key" "default" {
  algorithm = local.ssh_key_options.algorithm
}

locals {
  ssh_key = {
    public  = trimspace(tls_private_key.default.public_key_openssh)
    private = trimspace(tls_private_key.default.private_key_pem)
  }
}

output "ssh_key" {
  value = local.ssh_key
  sensitive = true
}
