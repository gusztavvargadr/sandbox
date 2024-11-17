terraform {
  required_version = "~> 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
}

variable "launch_template" {
  type = object({
    name = string

    ami_id = string

    instance_type = optional(string, "t3.micro")
    instance_spot = optional(bool, true)

    volume_type = optional(string, "gp3")
    volume_size = optional(number, 31)

    vpc_id = string

    public_key = string
    user_data  = optional(string, "")
  })
}

locals {
  launch_template_options = var.launch_template
}

resource "aws_security_group" "default" {
  name   = local.launch_template_options.name
  vpc_id = local.launch_template_options.vpc_id

  tags = {
    Name = local.launch_template_options.name
  }
}

resource "aws_key_pair" "default" {
  key_name   = local.launch_template_options.name
  public_key = local.launch_template_options.public_key

  tags = {
    Name = local.launch_template_options.name
  }
}

data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "default" {
  name               = local.launch_template_options.name
  assume_role_policy = data.aws_iam_policy_document.default.json

  tags = {
    Name = local.launch_template_options.name
  }
}

resource "aws_iam_instance_profile" "default" {
  name = local.launch_template_options.name
  role = aws_iam_role.default.name

  tags = {
    Name = local.launch_template_options.name
  }
}

resource "aws_launch_template" "default" {
  name = local.launch_template_options.name

  image_id = local.launch_template_options.ami_id

  instance_type = local.launch_template_options.instance_type
  dynamic "instance_market_options" {
    for_each = local.launch_template_options.instance_spot ? ["spot"] : []
    content {
      market_type = instance_market_options.value
    }
  }

  ebs_optimized = true
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type = local.launch_template_options.volume_type
      volume_size = local.launch_template_options.volume_size
    }
  }

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  key_name  = aws_key_pair.default.key_name
  user_data = base64encode(local.launch_template_options.user_data)

  iam_instance_profile {
    name = aws_iam_instance_profile.default.name
  }

  dynamic "tag_specifications" {
    for_each = concat(["instance", "volume", "network-interface"], (local.launch_template_options.instance_spot ? ["spot-instances-request"] : []))
    content {
      resource_type = tag_specifications.value
      tags          = aws_security_group.default.tags_all
    }
  }

  tags = {
    Name = local.launch_template_options.name
  }
}

locals {
  launch_template = {
    id   = aws_launch_template.default.id
    name = aws_launch_template.default.name

    security_group_id = aws_security_group.default.id
    security_group_name = aws_security_group.default.name

    role_id = aws_iam_role.default.id
    role_name = aws_iam_role.default.name
  }
}

output "launch_template" {
  value = local.launch_template
}
