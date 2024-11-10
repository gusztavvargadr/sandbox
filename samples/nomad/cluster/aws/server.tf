locals {
  server_options = {
    name = "${local.deployment.name}.server"

    instance_count = var.server.instance_count
    instance_type  = var.server.instance_type

    template = "${path.root}/server.userdata.sh"
  }
}

locals {
  server_launch_template_options = {
    name = local.server_options.name

    ami_id = local.ami.id

    instance_type = local.server_options.instance_type

    vpc_id = local.vpc.id

    public_key = module.ssh_key.ssh_key.public
    user_data = templatefile(local.server_options.template, {
      bucket = local.s3.bucket_name
    })
  }
}

module "server_launch_template" {
  source = "../../../../src/aws/ec2-launch-template"

  launch_template = local.server_launch_template_options
}

locals {
  server_launch_template = module.server_launch_template.launch_template
}

resource "aws_vpc_security_group_egress_rule" "server_internet" {
  security_group_id = local.server_launch_template.security_group_id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "internet"
  }
}

resource "aws_vpc_security_group_ingress_rule" "server_internet" {
  security_group_id = local.server_launch_template.security_group_id

  ip_protocol = "-1"
  cidr_ipv4   = "${local.local_ip}/32"

  tags = {
    Name = "internet"
  }
}

resource "aws_vpc_security_group_ingress_rule" "server_cluster_bootstrap" {
  security_group_id = local.server_launch_template.security_group_id

  ip_protocol                  = "-1"
  referenced_security_group_id = local.bootstrap_launch_template.security_group_id

  tags = {
    Name = "cluster-bootstrap"
  }
}

resource "aws_vpc_security_group_ingress_rule" "server_cluster_server" {
  security_group_id = local.server_launch_template.security_group_id

  ip_protocol                  = "-1"
  referenced_security_group_id = local.server_launch_template.security_group_id

  tags = {
    Name = "cluster-server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "server_cluster_client" {
  security_group_id = local.server_launch_template.security_group_id

  ip_protocol                  = "-1"
  referenced_security_group_id = local.client_launch_template.security_group_id

  tags = {
    Name = "cluster-client"
  }
}

resource "aws_iam_role_policy_attachment" "server_s3" {
  role       = local.server_launch_template.role_name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_autoscaling_group" "server" {
  name = local.server_options.name

  launch_template {
    id = local.server_launch_template.id
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

    script = "${path.root}/server.provision.sh"
  }
}

resource "terraform_data" "server_provision" {
  triggers_replace = [
    local.server_instances[count.index].public_ip,
    filemd5(local.server_provision_options.script),
  ]

  connection {
    type        = local.server_provision_options.type
    host        = local.server_instances[count.index].public_ip
    user        = local.server_provision_options.user
    private_key = local.server_provision_options.private_key
  }

  provisioner "remote-exec" {
    inline = ["sudo cloud-init status --wait"]
  }

  provisioner "remote-exec" {
    script = local.server_provision_options.script
  }

  count = length(local.server_instances)
}
