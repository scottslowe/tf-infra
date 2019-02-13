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

variable "registry_resource_group" {
  type = "string"
}

variable "registry_name" {
  type = "string"
}

variable "registry_subscription_id" {
  type = "string"
}

#This will be created manually
# variable "server_app_name" {
#   type    = "string"
#   default = "sandbox-aks-aawd-server"
# }


# variable "client_app_name" {
#   type    = "string"
#   default = "sandbox-aks-aad-client"
# }

