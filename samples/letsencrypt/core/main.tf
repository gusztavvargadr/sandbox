locals {
  deployment_options = {
    stack       = var.deployment.stack
    service     = var.deployment.service
    environment = coalesce(var.deployment.environment, terraform.workspace)
  }
}

locals {
  deployment = {
    name        = "${local.deployment_options.stack}.${local.deployment_options.service}.${local.deployment_options.environment}"
    stack       = local.deployment_options.stack
    service     = local.deployment_options.service
    environment = local.deployment_options.environment
  }
}

locals {
  domain_options = var.domain
}

locals {
  domain = {
    name  = local.domain_options.name
    fqdn  = "${replace(local.deployment.name, ".", "-")}.${local.domain_options.name}"
    email = "${local.deployment.name}@${local.domain_options.name}"
  }
}

locals {
  acme_options = var.acme
}

locals {
  acme = local.acme_options
}
