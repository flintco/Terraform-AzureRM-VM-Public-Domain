#Application Abbrevation (this will be used as a prefix for your resources)
variable "abbreviation" {
  type = string
  default = "app"
}

#Domain Name

#Azure Region (Region where your resources will be physically located)
#Default eastus

#VM Admin Username. You will use this when you SSH into VM.
#Default should be adminuser

#VM Size


/*For all:
type = string
default = "";

To access in terrafrom var.DomainName