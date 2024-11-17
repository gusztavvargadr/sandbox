packer {
  required_version = "~> 1.11.1"

  required_plugins {
    amazon = {
      version = "~> 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = "${formatdate("YYMMDD'-'hhmmss", timestamp())}"
  vm_name   = "gusztavvargadr-general-nomad-cluster-${local.timestamp}"

  source_options = {
    region   = "eu-west-1"
    ami_name = local.vm_name

    spot_price          = "auto"
    spot_instance_types = ["c7i.xlarge"]

    ebs_optimized              = true
    disk_device_name           = "/dev/sda1"
    disk_size                  = "31"
    disk_type                  = "gp3"
    disk_delete_on_termination = true

    communicator = {
      type     = "ssh"
      username = "ubuntu"
      timeout  = "30m"
    }

    tags = {
      "Name"    = local.vm_name
      "Stack"   = "gusztavvargadr-general"
      "Service" = "nomad-cluster"
    }
  }
}

source "amazon-ebs" "core" {
  region   = local.source_options.region
  ami_name = local.source_options.ami_name

  spot_price          = local.source_options.spot_price
  spot_instance_types = local.source_options.spot_instance_types

  ebs_optimized = local.source_options.ebs_optimized

  launch_block_device_mappings {
    device_name           = local.source_options.disk_device_name
    volume_size           = local.source_options.disk_size
    volume_type           = local.source_options.disk_type
    delete_on_termination = local.source_options.disk_delete_on_termination
  }

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }

    owners = ["amazon"]

    most_recent = true
  }

  run_tags        = local.source_options.tags
  run_volume_tags = local.source_options.tags

  communicator = local.source_options.communicator.type
  ssh_username = local.source_options.communicator.username
  ssh_timeout  = local.source_options.communicator.timeout
}

build {
  sources = [ "source.amazon-ebs.core" ]

  provisioner "shell" {
    inline = [ "mkdir -p /var/tmp/cluster" ]
  }

  provisioner "file" {
    source      = "${path.root}/../../core/"
    destination = "/var/tmp/cluster"
  }

  provisioner "shell" {
    script = "${path.root}/initialize.sh"
  }
}
