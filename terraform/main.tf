terraform {
    required_providers {
        azurerm= {
            source = "hashicorp/azurerm"
            version = "~> 3.90"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-zerotrust-lab"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-zerotrust-lab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-lab"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}