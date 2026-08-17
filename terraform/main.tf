# Déclaration du provider requis
terraform {
    required_providers {
        azurerm= {
            source = "hashicorp/azurerm"
            version = "~> 3.90"
        }
        http = {
            source  = "hashicorp/http"
            version = "~> 3.4"
        }
    }
}

# Activation du provider

provider "azurerm" {
    features {}
}

# première ressource : le Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "rg-zerotrust-lab"
  location = "spaincentral"
}

# deuxième ressource : azurerm_virtual_network

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-zerotrust-lab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Type de ressource : azurerm_subnet

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-lab"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

# Network Security Group (NSG)

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-zerotrust-lab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


  security_rule {
    name                       = "Allow-WireGuard"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# créationn de la ressource azurerm_public_ip

resource "azurerm_public_ip" "pip" {
  name                = "pip-zerotrust-lab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# azurerm_network_interface (NIC)

resource "azurerm_network_interface" "nic" {
  name                = "nic-zerotrust-lab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


# azurerm_network_interface_security_group_association 

resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id     = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# azurerm_linux_virtual_machine

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-zerotrust-lab"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}