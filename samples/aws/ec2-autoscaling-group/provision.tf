locals {
  provision_options = {
    type        = "ssh"
    user        = local.ami_options.user
    private_key = module.ssh_key.ssh_key.private

    script = "${path.root}/provision.sh"
  }
}

resource "terraform_data" "provision" {
  triggers_replace = [
    local.instances[count.index].ipv4_public,
    filemd5(local.provision_options.script)
  ]

  connection {
    type        = local.provision_options.type
    host        = local.instances[count.index].ipv4_public
    user        = local.provision_options.user
    private_key = local.provision_options.private_key
  }

  provisioner "remote-exec" {
    script = local.provision_options.script
  }

  count = length(local.instances)
}
