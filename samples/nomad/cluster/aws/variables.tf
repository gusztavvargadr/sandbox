variable "deployment" {
  type = object({
    stack       = optional(string, "gusztavvargadr-general")
    service     = optional(string, "nomad-cluster")
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

variable "bootstrap" {
  type = object({
    instance_count = optional(number, 1)
    instance_type  = optional(string, "t3.micro")
  })
  default = {}
}

variable "server" {
  type = object({
    instance_count = optional(number, 0)
    instance_type  = optional(string, "t3.micro")
  })
  default = {}
}

variable "client" {
  type = object({
    instance_count = optional(number, 0)
    instance_type  = optional(string, "t3.micro")
  })
  default = {}
}
