variable "environment_name" {
  type    = "string"
  default = "akstest"
}

variable cluster_name {
  type    = "string"
  default = "akstest-cluster"
}

variable "tags" {
  type = "map"

  default = {
    TechnicalOwner = "lowes@vmware.com"
    CostCenter     = "N/A"
    ABCID          = "N/A"
    Shared         = "No"
    environment    = "KP-Azure-AKSTest"
  }
}

variable location {
  type    = "string"
  default = "West US 2"
}

variable "vnet_name" {
  type    = "string"
  default = "akstest-vnet"
}

variable "subnet_name" {
  type        = "string"
  description = "The name of the subnet in the correct format name-CIDR"
  default     = "akstest-subnet"
}

variable "subnet_address_prefix" {
  type        = "string"
  description = "The address prefix for the subnet to be used by the AKS cluster"
  default     = "10.10.141.0/24"
}

variable "vnet_address_space" {
  type    = "list"
  default = ["10.10.140.0/23"]
}

variable "vnet_dns_servers" {
  type    = "list"
  default = ["8.8.8.8", "8.8.4.4"]
}

variable "vnet_resource_group_name" {
  type    = "string"
  default = "akstest-vnet-rg"
}
