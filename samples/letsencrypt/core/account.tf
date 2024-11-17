locals {
  account_options = {
    email = local.domain.email
  }
}

module "ssh_key_account" {
  source = "../../../src/core/ssh-key"
}

resource "acme_registration" "default" {
  email_address   = local.account_options.email
  account_key_pem = module.ssh_key_account.ssh_key.private
}

locals {
  account = {
    id          = acme_registration.default.id
    email       = acme_registration.default.email_address
    key_public  = module.ssh_key_account.ssh_key.public
    key_private = acme_registration.default.account_key_pem
  }
}
