locals {
  ami_options = var.ami
}

module "ami" {
  source = "../../../../src/aws/ec2-ami-data"

  ami = local.ami_options
}

locals {
  ami = module.ami.ami
}

module "vpc" {
  source = "../../../../src/aws/vpc-data"
}

locals {
  vpc = module.vpc.vpc
}

module "ssh_key" {
  source = "../../../../src/core/ssh-key"
}

data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  local_ip = trimspace(data.http.local_ip.response_body)
}
