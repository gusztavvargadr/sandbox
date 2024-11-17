terraform {
  required_version = "~> 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
}

variable "vpc" {
  type = object({
    name = optional(string, "default")
  })
  default = {}
}

locals {
  vpc_options = var.vpc
}

data "aws_vpc" "default" {
  tags = {
    Name = local.vpc_options.name
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

locals {
  vpc = {
    id   = data.aws_vpc.default.id
    name = data.aws_vpc.default.tags.Name

    public_subnet_ids = data.aws_subnets.public.ids
  }
}

output "vpc" {
  value = local.vpc
}
