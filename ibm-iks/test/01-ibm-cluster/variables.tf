variable "cluster_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "datacenter" {
  type = "string"
}

variable "machine_type" {
  type = "string"
}

variable "slack_api_webhook" {
  type = "string"
}

variable "default_pool_size" {
  type        = "string"
  description = "number of nodes to create in the default worker pool"
}
