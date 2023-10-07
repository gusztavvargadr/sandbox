locals {
  ssh_key_name = local.deployment_name
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

locals {
  ssh_key_public  = trimspace(tls_private_key.ssh_key.public_key_openssh)
  ssh_key_private = trimspace(tls_private_key.ssh_key.private_key_pem)
}

output "ssh_key_name" {
  value = local.ssh_key_name
}

output "ssh_key_public" {
  value = local.ssh_key_public
}

output "ssh_key_private" {
  value     = local.ssh_key_private
  sensitive = true
}

resource "local_file" "ssh_key_public" {
  filename = "${path.root}/.terraform/ssh-key-${local.ssh_key_name}.pub"
  content  = local.ssh_key_public
}

resource "local_sensitive_file" "ssh_key_private" {
  filename = "${path.root}/.terraform/ssh-key-${local.ssh_key_name}"
  content  = local.ssh_key_private
}

resource "aws_key_pair" "ssh_key" {
  key_name   = local.ssh_key_name
  public_key = local.ssh_key_public

  tags = {
    Name = local.ssh_key_name
  }
}

locals {
  ssh_key_id = aws_key_pair.ssh_key.id
}

output "ssh_key_id" {
  value = local.ssh_key_id
}
