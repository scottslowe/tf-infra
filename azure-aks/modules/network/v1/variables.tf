variable "common_tags" {
  type = "map"
}

variable cluster_name {
  type = "string"
}

variable "vnet_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "vnet_address_space" {
  type    = "list"
  default = ["10.10.140.0/23"]
}

variable "vnet_dns_servers" {
  type    = "list"
  default = ["172.27.166.69", "172.27.198.147"]
}

variable "vnet_resource_group_name" {
  type = "string"
}

variable "subnet_address_prefix" {
  type        = "string"
  description = "The address prefix for the subnet to be used by the AKS cluster"
  default     = "10.10.141.0/24"
}

variable "subnet_name" {
  type        = "string"
  description = "The name of the subnet in the correct format name-CIDR"
  default     = "AKSDEV01-10.10.141.0_25"
}
