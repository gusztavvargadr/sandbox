variable "deployment" {
  type = object({
    stack       = optional(string, "gusztavvargadr-general")
    service     = optional(string, "aws-ec2-instance")
    environment = optional(string)
  })
  default = {}
}

variable "aws" {
  type = object({
    region = optional(string, "eu-west-1")
  })
  default = {}
}

variable "ami" {
  type = object({
    name = optional(string, "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*")
    user = optional(string, "ubuntu")
  })
  default = {}
}

variable "instance" {
  type = object({
    count = optional(number, 1)
  })
  default = {}
}
