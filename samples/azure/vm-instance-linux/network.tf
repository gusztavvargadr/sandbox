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

data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  local_ip = trimspace(data.http.local_ip.response_body)
}

locals {
  security_group_name = local.deployment_name
}

resource "azurerm_network_security_group" "network" {
  resource_group_name = local.resource_group_name

  name     = local.network_name
  location = local.location_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${local.local_ip}/32"
    destination_address_prefix = "*"
  }
}

locals {
  security_group_id = azurerm_network_security_group.network.id
}
