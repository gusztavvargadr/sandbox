locals {
  server_options = {
    name = "${local.deployment.name}.server"

    instance_count = var.server.instance_count
    instance_type  = var.server.instance_type
  }
}

resource "aws_autoscaling_group" "server" {
  name = local.server_options.name

  launch_template {
    id = local.launch_template.id
  }

  vpc_zone_identifier = local.vpc.public_subnet_ids

  min_size         = local.server_options.instance_count
  max_size         = local.server_options.instance_count
  desired_capacity = local.server_options.instance_count

  tag {
    key                 = "Name"
    value               = local.server_options.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.aws.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}

locals {
  server_autoscaling_group = {
    id   = aws_autoscaling_group.server.id
    name = aws_autoscaling_group.server.name
  }
}

resource "aws_s3_object" "server_config" {
  bucket = aws_s3_bucket.default.bucket
  key    = "server/config/nomad.hcl"
  source = "${path.root}/server/artifacts/config/nomad.hcl"
  count  = fileexists("${path.root}/server/artifacts/config/nomad.hcl") ? 1 : 0
}

resource "aws_s3_object" "server_ca_cert" {
  bucket = aws_s3_bucket.default.bucket
  key    = "server/config/tls/ca-cert.pem"
  source = "${path.root}/server/artifacts/config/tls/ca-cert.pem"
  count  = fileexists("${path.root}/server/artifacts/config/tls/ca-cert.pem") ? 1 : 0
}

resource "aws_s3_object" "server_nomad_cert" {
  bucket = aws_s3_bucket.default.bucket
  key    = "server/config/tls/nomad-cert.pem"
  source = "${path.root}/server/artifacts/config/tls/nomad-cert.pem"
  count  = fileexists("${path.root}/server/artifacts/config/tls/nomad-cert.pem") ? 1 : 0
}

resource "aws_s3_object" "server_nomad_key" {
  bucket = aws_s3_bucket.default.bucket
  key    = "server/config/tls/nomad-key.pem"
  source = "${path.root}/server/artifacts/config/tls/nomad-key.pem"
  count  = fileexists("${path.root}/server/artifacts/config/tls/nomad-key.pem") ? 1 : 0
}

data "aws_instances" "server" {
  instance_tags = {
    Name = local.server_options.name
  }
}

data "aws_instance" "server" {
  instance_id = data.aws_instances.server.ids[count.index]

  count = length(data.aws_instances.server.ids)
}

locals {
  server_instances = [for instance in data.aws_instance.server : {
    id         = instance.id
    name       = instance.tags.Name
    public_ip  = instance.public_ip
    private_ip = instance.private_ip
  }]
}

locals {
  server_provision_options = {
    type        = "ssh"
    user        = local.ami_options.user
    private_key = module.ssh_key.ssh_key.private

    template = "${path.root}/server.sh"
    script   = "${path.root}/server/artifacts/provision.sh"
  }
}

resource "local_file" "server_provision" {
  filename = local.server_provision_options.script
  content = templatefile(local.server_provision_options.template, {
    bucket = local.s3.bucket_name
  })
}

resource "terraform_data" "server_provision" {
  triggers_replace = [
    local.server_instances[count.index].public_ip,
    filemd5(local_file.server_provision.filename)
  ]

  connection {
    type        = local.server_provision_options.type
    host        = local.server_instances[count.index].public_ip
    user        = local.server_provision_options.user
    private_key = local.server_provision_options.private_key
  }

  provisioner "remote-exec" {
    script = local.server_provision_options.script
  }

  count = length(local.server_instances)
}
