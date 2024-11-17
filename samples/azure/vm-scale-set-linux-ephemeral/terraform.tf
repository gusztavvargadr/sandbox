terraform {
  required_version = "~> 1.5"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}
