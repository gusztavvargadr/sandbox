terraform {
  required_version = "~> 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "consul" {
    path = "gusztavvargadr-general.nomad-cluster/terraform/state"
    gzip = true
  }
}

provider "aws" {
  region = local.aws_options.region

  default_tags {
    tags = local.aws_options.tags
  }
}
