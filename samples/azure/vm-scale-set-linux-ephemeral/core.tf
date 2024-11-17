variable "component_name" {
  type    = string
  default = "general-azure-vm-scale-set-l3x-ephemeral"
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "location_name" {
  type    = string
  default = "West Europe"
}

locals {
  environment_name = coalesce(var.environment_name, terraform.workspace)
  deployment_name  = "${var.component_name}-${local.environment_name}"
  location_name    = var.location_name
}

output "deployment_name" {
  value = local.deployment_name
}

locals {
  resource_group_name_argument = local.deployment_name
}

resource "azurerm_resource_group" "core" {
  name     = local.resource_group_name_argument
  location = local.location_name
}

locals {
  resource_group_name = azurerm_resource_group.core.name
}

output "resource_group_name" {
  value = local.resource_group_name
}
