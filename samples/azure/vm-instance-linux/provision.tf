locals {
  provision_type        = "ssh"
  provision_host        = local.instance_ip
  provision_user        = local.instance_user
  provision_private_key = local.ssh_key_private
  provision_script      = "${path.root}/provision.sh"
}

resource "terraform_data" "provision" {
  triggers_replace = [
    local.provision_host
  ]

  connection {
    type        = local.provision_type
    host        = local.provision_host
    user        = local.provision_user
    private_key = local.provision_private_key
  }

  provisioner "remote-exec" {
    script = local.provision_script
  }
}
