provider "oci" {
  version          = ">= 3.0.0"
  region           = "${var.oci_region}"
  tenancy_ocid     = "${var.oci_tenancy_ocid}"
  user_ocid        = "${var.oci_user_ocid}"
  fingerprint      = "${var.oci_fingerprint}"
  private_key_path = "${var.oci_private_key_path}"
}

provider "aws" {
  version = "~> 1.40"
  region  = "us-east-2"
}

provider "tls" {
  version = "~> 1.2"
}
