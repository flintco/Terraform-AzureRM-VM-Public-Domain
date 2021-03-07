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

#Create a Network Security Group. This controls traffic coming in and going out of VM
resource "azurerm_network_security_group" "nsg"{
  name = "NetworkSecurityGroup"
  location = "eastus"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule = {
    access = "Allow"
    destination_address_prefix = "*"
    destination_port_range = "22"
    direction = "Inbound"
    name = "SSH"
    priority = 1001
    protocol = "TCP"
    source_address_prefix = "*"
    source_port_range = "*"
  }

}

#Create a Network Interface Card to connect VM, Public IP, and Vnet
resource "azurerm_network_interface" "nic"{
  name = "NetworkInterfaceCard"
  location = "eastUS"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "NicConfig"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

#Connect Security Group to NIC
resource "azurerm_network_interface_security_group_association" "connection"{
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#Create SSH Key
resource "tls_private_key" "pkey"{
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

# Create Linux VM and connect to NIC
#TODO: Figure out SSH key for linux vm
resource "azurerm_linux_virtual_machine" "lvm"{
  name = "LinuxVM"
  loaction = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_DS1_v2"

  os_disk {
    name = "myOsDisk"
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  computer_name  = "myvm"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username = "AzureUser"
    public_key = tls_private_key.pkey.public_key_openssh
  }

}

#Create DNS Zone
resource "azure_dns_zone" "dzone"{
  name = "mydomain.com"
  resource_group_name = azurerm_resource_group.rg.name
}

#Create DNS A Record
resource "azurerm_dns_a_record" "arecord" {
  name = "DnsARecord"
  zone_name = azurerm_dns_zone.dzone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 300
  target_resource_id = azurerm_public_ip.pip.name
}