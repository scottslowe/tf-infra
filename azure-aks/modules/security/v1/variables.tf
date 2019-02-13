variable "vnet_name" {
  type = "string"
}

variable "vnet_resource_group_name" {
  type = "string"
}

variable "subnet_name" {
  type = "string"
}

variable "registry_name" {
  type = "string"
}

variable "registry_resource_group" {
  type = "string"
}

variable "environment_name" {
  type = "string"
}

variable "password_expiration" {
  default = "2020-01-01T01:02:03Z"
}

variable "registry_subscription_id" {
  type = "string"
}
