locals {
  client_options = {
    name = "${local.deployment.name}.client"

    instance_count = var.client.instance_count
    instance_type  = var.client.instance_type

    template = "${path.root}/client.userdata.sh"
  }
}

locals {
  client_launch_template_options = {
    name = local.client_options.name

    ami_id = local.ami.id

    instance_type = local.client_options.instance_type

    vpc_id = local.vpc.id

    public_key = module.ssh_key.ssh_key.public
    user_data = templatefile(local.client_options.template, {
      bucket = local.s3.bucket_name
    })
  }
}

module "client_launch_template" {
  source = "../../../../src/aws/ec2-launch-template"

  launch_template = local.client_launch_template_options
}

locals {
  client_launch_template = module.client_launch_template.launch_template
}

resource "aws_vpc_security_group_egress_rule" "client_internet" {
  security_group_id = local.client_launch_template.security_group_id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "internet"
  }
}

resource "aws_vpc_security_group_ingress_rule" "client_internet" {
  security_group_id = local.client_launch_template.security_group_id

  ip_protocol = "-1"
  cidr_ipv4   = "${local.local_ip}/32"

  tags = {
    Name = "internet"
  }
}

resource "aws_vpc_security_group_ingress_rule" "client_cluster_bootstrap" {
  security_group_id = local.client_launch_template.security_group_id

  ip_protocol                  = "-1"
  referenced_security_group_id = local.bootstrap_launch_template.security_group_id

  tags = {
    Name = "cluster-bootstrap"
  }
}

resource "aws_vpc_security_group_ingress_rule" "client_cluster_server" {
  security_group_id = local.client_launch_template.security_group_id

  ip_protocol                  = "-1"
  referenced_security_group_id = local.server_launch_template.security_group_id

  tags = {
    Name = "cluster-server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "client_cluster_client" {
  security_group_id = local.client_launch_template.security_group_id

  ip_protocol                  = "-1"
  referenced_security_group_id = local.client_launch_template.security_group_id

  tags = {
    Name = "cluster-client"
  }
}

resource "aws_iam_role_policy_attachment" "client_s3" {
  role       = local.client_launch_template.role_name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_autoscaling_group" "client" {
  name = local.client_options.name

  launch_template {
    id = local.client_launch_template.id
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

    script = "${path.root}/client.provision.sh"
  }
}

resource "terraform_data" "client_provision" {
  triggers_replace = [
    local.client_instances[count.index].public_ip,
    filemd5(local.client_provision_options.script)
  ]

  connection {
    type        = local.client_provision_options.type
    host        = local.client_instances[count.index].public_ip
    user        = local.client_provision_options.user
    private_key = local.client_provision_options.private_key
  }

  provisioner "remote-exec" {
    inline = ["sudo cloud-init status --wait"]
  }

  provisioner "remote-exec" {
    script = local.client_provision_options.script
  }

  count = length(local.client_instances)
}
