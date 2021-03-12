#Application Abbrevation (this will be used as a prefix for your resources)
variable "abbreviation" {
  type = string
  default = "app"
}

#Domain Name
variable "domain" {
  type = string
  default = "mysite.com"
}

#Azure Region (Region where your resources will be physically located)
variable "location" {
  type = string
  default = "eastus"
}

#VM Admin Username. You will use this when you SSH into VM.
variable "admin" {
  type = string
  default = "adminuser"
}

#VM Size
variable "vmsize" {
  type = string
  default = "Standard_DS1_v2"
}

//To access in terrafrom var.DomainName