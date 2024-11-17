locals {
  ami_options = var.ami
}

module "ami" {
  source = "../../../src/aws/ec2-ami-data"

  ami = local.ami_options
}

locals {
  ami = module.ami.ami
}

module "vpc" {
  source = "../../../src/aws/vpc-data"
}

locals {
  vpc = module.vpc.vpc
}

module "ssh_key" {
  source = "../../../src/core/ssh-key"
}

locals {
  launch_template_options = {
    name = local.deployment.name

    ami_id = local.ami.id

    vpc_id = local.vpc.id

    public_key = module.ssh_key.ssh_key.public
    user_data  = file("${path.root}/user-data.sh")
  }
}

module "launch_template" {
  source = "../../../src/aws/ec2-launch-template"

  launch_template = local.launch_template_options
}

locals {
  launch_template = module.launch_template.launch_template
}

resource "aws_vpc_security_group_egress_rule" "ipv4_all" {
  security_group_id = local.launch_template.security_group_id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ipv4-all"
  }
}

data "http" "ipv4_local" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  ipv4_local = trimspace(data.http.ipv4_local.response_body)
}

resource "aws_vpc_security_group_ingress_rule" "ipv4_ssh" {
  security_group_id = local.launch_template.security_group_id

  ip_protocol = "tcp"
  cidr_ipv4   = "${local.ipv4_local}/32"
  from_port   = 22
  to_port     = 22

  tags = {
    Name = "ipv4-ssh"
  }
}
