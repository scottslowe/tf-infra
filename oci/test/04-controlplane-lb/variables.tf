variable "oci_region" {
  description = "Region in which to create all resources"
  type        = "string"
  default     = "us-phoenix-1"
}

variable "oci_tenancy_ocid" {
  description = "OCID for the tenant"
  type        = "string"
}

variable "oci_user_ocid" {
  description = "OCID for the user"
  type        = "string"
}

variable "oci_fingerprint" {
  description = "Fingerprint for API key"
  type        = "string"
}

variable "oci_private_key_path" {
  description = "Path to private key portion of API key"
  type        = "string"
}

variable "oci_lb_shape" {
  description = "Load balancer shape"
  type = "string"
  default = "100Mbps"
}

variable "cp_is_ha" {
  description = "Boolean indicated HA control plane (multiple CP nodes)"
  type = "string"
  default = "true"
}

variable "cp_port" {
  description = "Port on which the CP LB and nodes should listen"
  type = "string"
  default = "6443"
}
