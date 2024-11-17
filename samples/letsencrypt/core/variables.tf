variable "deployment" {
  type = object({
    stack       = optional(string, "gusztavvargadr-general")
    service     = optional(string, "letsencrypt-core")
    environment = optional(string)
  })
  default = {}
}

variable "domain" {
  type = object({
    name = optional(string, "gusztavvargadr.me")
  })
  default = {}
}

variable "acme" {
  type = object({
    server    = optional(string, "https://acme-v02.api.letsencrypt.org/directory")
    challenge = optional(string, "route53")
  })
  default = {}
}
