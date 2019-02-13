variable "public_vlan_name" {
  type = "string"
}

variable "datacenter" {
  type = "string"
}

variable "private_vlan_name" {
  type = "string"
}

variable "tags" {
  type        = "list"
  description = "List of strings"
}
