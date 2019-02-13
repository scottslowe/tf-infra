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

variable "aks_resource_group_name" {
  type = "string"
}

variable dns_prefix {
  type    = "string"
  default = "akstest"
}

variable location {
  type    = "string"
  default = "West US 2"
}

variable agent_count {
  type    = "string"
  default = "2"
}

variable "ssh_public_key" {
  type = "string"
}

variable k8s_version {
  type    = "string"
  default = "1.11.5"
}

variable vm_size {
  type    = "string"
  default = "Standard_D2s_v3"
}

variable os_disk_size_gb {
  type    = "string"
  default = 30
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
