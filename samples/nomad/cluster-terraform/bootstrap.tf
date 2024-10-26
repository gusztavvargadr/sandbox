locals {
  bootstrap_options = {
    name = "${local.deployment.name}.bootstrap"

    instance_count = var.bootstrap.instance_count
    instance_type  = var.bootstrap.instance_type
  }
}

resource "aws_autoscaling_group" "bootstrap" {
  name = local.bootstrap_options.name

  launch_template {
    id = local.launch_template.id
  }

  vpc_zone_identifier = local.vpc.public_subnet_ids

  min_size         = local.bootstrap_options.instance_count
  max_size         = local.bootstrap_options.instance_count
  desired_capacity = local.bootstrap_options.instance_count

  tag {
    key                 = "Name"
    value               = local.bootstrap_options.name
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
  bootstrap_autoscaling_group = {
    id   = aws_autoscaling_group.bootstrap.id
    name = aws_autoscaling_group.bootstrap.name
  }
}

resource "aws_s3_object" "bootstrap_config" {
  bucket = aws_s3_bucket.default.bucket
  key    = "bootstrap/config/nomad.hcl"
  source = "${path.root}/bootstrap/artifacts/config/nomad.hcl"
  count  = fileexists("${path.root}/bootstrap/artifacts/config/nomad.hcl") ? 1 : 0
}

resource "aws_s3_object" "bootstrap_ca_cert" {
  bucket = aws_s3_bucket.default.bucket
  key    = "bootstrap/config/tls/ca-cert.pem"
  source = "${path.root}/bootstrap/artifacts/config/tls/ca-cert.pem"
  count  = fileexists("${path.root}/bootstrap/artifacts/config/tls/ca-cert.pem") ? 1 : 0
}

resource "aws_s3_object" "bootstrap_nomad_cert" {
  bucket = aws_s3_bucket.default.bucket
  key    = "bootstrap/config/tls/nomad-cert.pem"
  source = "${path.root}/bootstrap/artifacts/config/tls/nomad-cert.pem"
  count  = fileexists("${path.root}/bootstrap/artifacts/config/tls/nomad-cert.pem") ? 1 : 0
}

resource "aws_s3_object" "bootstrap_nomad_key" {
  bucket = aws_s3_bucket.default.bucket
  key    = "bootstrap/config/tls/nomad-key.pem"
  source = "${path.root}/bootstrap/artifacts/config/tls/nomad-key.pem"
  count  = fileexists("${path.root}/bootstrap/artifacts/config/tls/nomad-key.pem") ? 1 : 0
}

data "aws_instances" "bootstrap" {
  instance_tags = {
    Name = local.bootstrap_options.name
  }
}

data "aws_instance" "bootstrap" {
  instance_id = data.aws_instances.bootstrap.ids[count.index]

  count = length(data.aws_instances.bootstrap.ids)
}

locals {
  bootstrap_instances = [for instance in data.aws_instance.bootstrap : {
    id         = instance.id
    name       = instance.tags.Name
    public_ip  = instance.public_ip
    private_ip = instance.private_ip
  }]
}

locals {
  bootstrap_provision_options = {
    type        = "ssh"
    user        = local.ami_options.user
    private_key = module.ssh_key.ssh_key.private

    template = "${path.root}/bootstrap.sh"
    script   = "${path.root}/bootstrap/artifacts/provision.sh"
  }
}

resource "local_file" "bootstrap_provision" {
  filename = local.bootstrap_provision_options.script
  content = templatefile(local.bootstrap_provision_options.template, {
    bucket = local.s3.bucket_name
  })
}

resource "terraform_data" "bootstrap_provision" {
  triggers_replace = [
    local.bootstrap_instances[count.index].public_ip,
    filemd5(local_file.bootstrap_provision.filename)
  ]

  connection {
    type        = local.bootstrap_provision_options.type
    host        = local.bootstrap_instances[count.index].public_ip
    user        = local.bootstrap_provision_options.user
    private_key = local.bootstrap_provision_options.private_key
  }

  provisioner "remote-exec" {
    script = local.bootstrap_provision_options.script
  }

  count = length(local.bootstrap_instances)
}

data "aws_s3_object" "bootstrap_token" {
  bucket = aws_s3_bucket.default.bucket
  key    = "core/acl/bootstrap.json"

  depends_on = [
    terraform_data.bootstrap_provision
  ]

  count = length(terraform_data.bootstrap_provision) > 0 ? 1 : 0
}

resource "local_sensitive_file" "bootstrap_token" {
  filename = "${path.root}/core/artifacts/acl/bootstrap.json"
  content  = data.aws_s3_object.bootstrap_token[0].body

  count = length(data.aws_s3_object.bootstrap_token) > 0 ? 1 : 0
}

locals {
  bootstrap_token = length(local_sensitive_file.bootstrap_token) > 0 ? jsondecode(local_sensitive_file.bootstrap_token[0].content) : null
}
