locals {
  instance_options = var.instance
}

resource "aws_instance" "default" {
  launch_template {
    id = local.launch_template.id
  }

  subnet_id = local.vpc.public_subnet_ids[count.index % length(local.vpc.public_subnet_ids)]

  tags = {
    Name = local.deployment.name
  }

  lifecycle {
    ignore_changes = [
      user_data
    ]
  }

  count = local.instance_options.count
}

locals {
  instances = [for instance in aws_instance.default : {
    id           = instance.id
    name         = instance.tags.Name
    ipv4_public  = instance.public_ip
    ipv4_private = instance.private_ip
  }]
}
