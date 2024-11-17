locals {
  certificate_options = {
    account     = local.account.key_private
    common_name = local.domain.fqdn
    challenge   = local.acme.challenge
  }
}

resource "acme_certificate" "default" {
  account_key_pem = local.certificate_options.account
  common_name     = local.certificate_options.common_name

  dns_challenge {
    provider = local.certificate_options.challenge
  }
}

locals {
  certificate = {
    id          = acme_certificate.default.id
    common_name = acme_certificate.default.common_name
    ca_cert     = acme_certificate.default.issuer_pem
    server_cert = acme_certificate.default.certificate_pem
    server_key  = acme_certificate.default.private_key_pem
  }
}
