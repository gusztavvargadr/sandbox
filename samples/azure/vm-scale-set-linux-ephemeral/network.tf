locals {
  network_name_argument = local.deployment_name
}

resource "azurerm_virtual_network" "network" {
  resource_group_name = local.resource_group_name

  name          = local.network_name_argument
  location      = local.location_name
  address_space = ["10.0.0.0/16"]
}

locals {
  network_id   = azurerm_virtual_network.network.id
  network_name = azurerm_virtual_network.network.name
}

resource "azurerm_subnet" "network" {
  resource_group_name = local.resource_group_name

  name                 = local.network_name
  virtual_network_name = local.network_name
  address_prefixes     = ["10.0.0.0/24"]
}

locals {
  subnet_id = azurerm_subnet.network.id
}
