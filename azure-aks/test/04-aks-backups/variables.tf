variable "environment_name" {
  type    = "string"
  default = "akstest"
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

variable "ark_resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
  default = "West US 2"
}

variable "ark_storage_acc_name" {
  type = "string"
}

variable "ark_blob_container_name" {
  type = "string"
}

variable "ark_storage_app_name" {
  type = "string"
}

variable "subscription_id" {
  type = "string"
}

variable "tenant_id" {
  type = "string"
}

variable "codebase_cluster_name" {
  type        = "string"
  description = "This is the name that corelates to a cluster inside the k8s/spec/clusters folder"
}
