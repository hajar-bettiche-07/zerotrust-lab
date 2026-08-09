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