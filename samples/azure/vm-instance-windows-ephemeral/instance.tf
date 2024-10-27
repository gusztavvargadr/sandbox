locals {
  instance_name = local.deployment_name

  instance_size         = "Standard_D8lds_v5"
  instance_user         = "windows"
  instance_disk_type    = "Standard_LRS"
  instance_disk_size    = 255
  instance_disk_caching = "ReadOnly"

  instance_image_publisher = "MicrosoftWindowsServer"
  instance_image_offer     = "WindowsServer"
  instance_image_sku       = "2022-datacenter-azure-edition-smalldisk"
  instance_image_version   = "latest"
}

resource "azurerm_public_ip" "instance" {
  resource_group_name = local.resource_group_name

  name              = local.instance_name
  location          = local.location_name
  allocation_method = "Static"
  sku               = "Standard"
}

locals {
  public_ip_id = azurerm_public_ip.instance.id
}

resource "azurerm_network_interface" "instance" {
  resource_group_name = local.resource_group_name

  name     = local.instance_name
  location = local.location_name

  ip_configuration {
    name                          = local.network_name
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.public_ip_id
  }
}

locals {
  network_interface_id = azurerm_network_interface.instance.id
}

resource "azurerm_network_interface_security_group_association" "instance" {
  network_interface_id      = local.network_interface_id
  network_security_group_id = local.security_group_id
}

resource "random_password" "instance" {
  length = 16
}

resource "azurerm_windows_virtual_machine" "instance" {
  resource_group_name = local.resource_group_name

  name     = local.instance_name
  location = local.location_name

  source_image_reference {
    publisher = local.instance_image_publisher
    offer     = local.instance_image_offer
    sku       = local.instance_image_sku
    version   = local.instance_image_version
  }

  computer_name = "windows"

  size            = local.instance_size
  priority        = "Spot"
  eviction_policy = "Delete"

  os_disk {
    storage_account_type = local.instance_disk_type
    disk_size_gb         = local.instance_disk_size
    caching              = local.instance_disk_caching

    diff_disk_settings {
      option    = "Local"
      placement = "ResourceDisk"
    }
  }

  network_interface_ids = [
    local.network_interface_id
  ]

  admin_username = local.instance_user
  admin_password = random_password.instance.result
}

locals {
  instance_id = azurerm_windows_virtual_machine.instance.id
  instance_ip = azurerm_windows_virtual_machine.instance.public_ip_address
}

output "instance_id" {
  value = local.instance_id
}

output "instance_name" {
  value = local.instance_name
}

output "instance_ip" {
  value = local.instance_ip
}

output "instance_password" {
  value     = azurerm_windows_virtual_machine.instance.admin_password
  sensitive = true
}
