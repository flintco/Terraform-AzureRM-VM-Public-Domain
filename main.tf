// join("", [var.abbreviation, "bar"])
# Configure the Azure Provider
provider "azurerm" {
  version = "=2.40.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = join("", [var.abbreviation, "-ResourceGroup"])
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "VirtualNetwork"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
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
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

#Create a Network Security Group. This controls traffic coming in and going out of VM
resource "azurerm_network_security_group" "nsg"{
  name = "NetworkSecurityGroup"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  #SSH Access
  security_rule {
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
  #HTTP access
  security_rule {
        name                       = "HTTP"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "nic" {
    name                        = "NetworkInterfaceCard"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip.id
    }
}

#Connect Security Group to NIC
resource "azurerm_network_interface_security_group_association" "connection"{
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "lvm" {
    name                  = "LinuxVM"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = var.admin
    disable_password_authentication = true

    /*Takes public key that is on the SSH client (in this case local computer that does Terraform apply)
    The computer that does Terraform apply will be able to SSH into VM that is created.
    NOTE: This stores SSH key in your state file  */

    admin_ssh_key {
        username = var.admin
        public_key = file("~/.ssh/id_rsa.pub")
    }
}

#Create DNS Zone
resource "azurerm_dns_zone" "dzone"{
  name = var.domain
  resource_group_name = azurerm_resource_group.rg.name
}

#Create DNS A Record
resource "azurerm_dns_a_record" "arecord" {
  name = "DnsARecord"
  zone_name = azurerm_dns_zone.dzone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 300
  target_resource_id = azurerm_public_ip.pip.id
}