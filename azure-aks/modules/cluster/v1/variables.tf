variable "common_tags" {
  type        = "map"
  description = "A map of common tags to apply"
}

variable vnet_resource_group_name {
  type = "string"
}

variable "aks_resource_group_name" {
  type = "string"
}

variable location {
  type = "string"
}

variable "subnet_name" {
  type = "string"
}

variable "vnet_name" {
  type = "string"
}

variable cluster_name {
  type = "string"
}

variable dns_prefix {
  type = "string"
}

variable k8s_version {
  type    = "string"
  default = "1.11.5"
}

variable agent_count {
  type = "string"
}

variable vm_size {
  type    = "string"
  default = "Standard_D2s_v3"
}

variable os_disk_size_gb {
  type    = "string"
  default = 30
}

variable max_pods_per_node {
  type    = "string"
  default = 100
}

variable client_id {
  type = "string"
}

variable "client_sp_id" {
  type = "string"
}

variable client_secret {
  type = "string"
}

variable "ssh_public_key" {
  description = "path to public ssh key"
  type        = "string"
}

variable "aad_client_id" {
  type = "string"
}

variable "aad_server_id" {
  type = "string"
}

variable "aad_server_secret" {
  type = "string"
}
