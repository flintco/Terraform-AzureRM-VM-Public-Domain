# Configure the Azure Provider
provider "azurerm" {
  version = "=2.40.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "ResourceGroup"
  location = "North Central US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "VirtualNetwork"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

#Create a subnet within the virtual network
resource "azurerm_subnet" "subnet"{
  name = "Subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}

#Create a public IP resource
resource "azurerm_public_ip" "pip"{
  name = "PublicIP"
  location = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

