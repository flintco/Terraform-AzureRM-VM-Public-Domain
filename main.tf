# Configure the Azure Provider
provider "azurerm" {
  version = "=2.40.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "Resource Group"
  location = "North Central US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "Virtual Network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

#Subnet comment
resource "azurerm_subnet" "subnet"{
  name = "Subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}