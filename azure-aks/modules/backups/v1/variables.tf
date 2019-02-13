variable "ark_resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "common_tags" {
  type = "map"
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

variable "password_expiration" {
  type    = "string"
  default = "2020-01-01T01:02:03Z"
}

variable "aks_cluster_name" {
  type        = "string"
  description = "This is the name of the cluster inside azure"
}

variable "codebase_cluster_name" {
  type        = "string"
  description = "This is the name that corelates to a cluster inside the k8s/spec/clusters folder"
}

variable "aks_resource_group_name" {
  type = "string"
}

variable "subscription_id" {
  type        = "string"
  description = "subscription id of where the cluster is created"
}

variable "tenant_id" {
  type = "string"
}
