locals {
  client_options = {
    name = "${local.deployment.name}.client"

    instance_count = var.client.instance_count
    instance_type  = var.client.instance_type
  }
}

resource "aws_autoscaling_group" "client" {
  name = local.client_options.name

  launch_template {
    id = local.launch_template.id
  }

  vpc_zone_identifier = local.vpc.public_subnet_ids

  min_size         = local.client_options.instance_count
  max_size         = local.client_options.instance_count
  desired_capacity = local.client_options.instance_count

  tag {
    key                 = "Name"
    value               = local.client_options.name
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
  client_autoscaling_group = {
    id   = aws_autoscaling_group.client.id
    name = aws_autoscaling_group.client.name
  }
}

resource "aws_s3_object" "client_config" {
  bucket = aws_s3_bucket.default.bucket
  key    = "client/config/nomad.hcl"
  source = "${path.root}/client/artifacts/config/nomad.hcl"
  count  = fileexists("${path.root}/client/artifacts/config/nomad.hcl") ? 1 : 0
}

resource "aws_s3_object" "client_ca_cert" {
  bucket = aws_s3_bucket.default.bucket
  key    = "client/config/tls/ca-cert.pem"
  source = "${path.root}/client/artifacts/config/tls/ca-cert.pem"
  count  = fileexists("${path.root}/client/artifacts/config/tls/ca-cert.pem") ? 1 : 0
}

resource "aws_s3_object" "client_nomad_cert" {
  bucket = aws_s3_bucket.default.bucket
  key    = "client/config/tls/nomad-cert.pem"
  source = "${path.root}/client/artifacts/config/tls/nomad-cert.pem"
  count  = fileexists("${path.root}/client/artifacts/config/tls/nomad-cert.pem") ? 1 : 0
}

resource "aws_s3_object" "client_nomad_key" {
  bucket = aws_s3_bucket.default.bucket
  key    = "client/config/tls/nomad-key.pem"
  source = "${path.root}/client/artifacts/config/tls/nomad-key.pem"
  count  = fileexists("${path.root}/client/artifacts/config/tls/nomad-key.pem") ? 1 : 0
}

data "aws_instances" "client" {
  instance_tags = {
    Name = local.client_options.name
  }
}

data "aws_instance" "client" {
  instance_id = data.aws_instances.client.ids[count.index]

  count = length(data.aws_instances.client.ids)
}

locals {
  client_instances = [for instance in data.aws_instance.client : {
    id         = instance.id
    name       = instance.tags.Name
    public_ip  = instance.public_ip
    private_ip = instance.private_ip
  }]
}

locals {
  client_provision_options = {
    type        = "ssh"
    user        = local.ami_options.user
    private_key = module.ssh_key.ssh_key.private

    template = "${path.root}/client.sh"
    script   = "${path.root}/client/artifacts/provision.sh"
  }
}

resource "local_file" "client_provision" {
  filename = local.client_provision_options.script
  content = templatefile(local.client_provision_options.template, {
    bucket = local.s3.bucket_name
  })
}

resource "terraform_data" "client_provision" {
  triggers_replace = [
    local.client_instances[count.index].public_ip,
    filemd5(local_file.client_provision.filename)
  ]

  connection {
    type        = local.client_provision_options.type
    host        = local.client_instances[count.index].public_ip
    user        = local.client_provision_options.user
    private_key = local.client_provision_options.private_key
  }

  provisioner "remote-exec" {
    script = local.client_provision_options.script
  }

  count = length(local.client_instances)
}
