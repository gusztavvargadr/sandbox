output "deployment" {
  value = local.deployment
}

output "domain" {
  value = local.domain
}

output "acme" {
  value = local.acme
}

output "account" {
  value     = local.certificate
  sensitive = true
}

output "certificate" {
  value     = local.certificate
  sensitive = true
}

resource "vault_mount" "default" {
  type = "kv-v2"
  path = "${local.deployment.name}/kv"
}

resource "vault_kv_secret_v2" "account" {
  mount     = vault_mount.default.path
  name      = "account"
  data_json = jsonencode(local.account)
}

resource "vault_kv_secret_v2" "certificate" {
  mount     = vault_mount.default.path
  name      = "certificate"
  data_json = jsonencode(local.certificate)
}

resource "local_file" "account_key_public" {
  filename = "${path.root}/artifacts/account/key-public"
  content  = local.account.key_public
}

resource "local_sensitive_file" "account_key_private" {
  filename = "${path.root}/artifacts/account/key-private"
  content  = local.account.key_private
}

resource "local_file" "certificate_ca_cert" {
  filename = "${path.root}/artifacts/certificate/ca-cert.pem"
  content  = local.certificate.ca_cert
}

resource "local_file" "certificate_server_cert" {
  filename = "${path.root}/artifacts/certificate/server-cert.pem"
  content  = local.certificate.server_cert
}

resource "local_sensitive_file" "certificate_server_key" {
  filename = "${path.root}/artifacts/certificate/server-key.pem"
  content  = local.certificate.server_key
}
