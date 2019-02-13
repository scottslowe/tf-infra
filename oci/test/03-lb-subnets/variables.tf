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
