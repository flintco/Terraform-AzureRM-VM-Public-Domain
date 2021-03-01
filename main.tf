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
resource "azurerm_virtual_network" "VNet" {
  name                = "Virtual Network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

#Subnet comment
