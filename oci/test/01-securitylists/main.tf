# Pull in remote state from VCN
data "terraform_remote_state" "vcn" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/vcn/terraform.tfstate"
    region = "us-east-2"
  }
}

# Create security list for the control plane nodes
# Ingress sources correspond to VCN CIDR
resource "oci_core_security_list" "cp_sec_list" {
  compartment_id = "${var.oci_tenancy_ocid}"
  display_name   = "${data.terraform_remote_state.vcn.env_name}-cp-sec-list"
  vcn_id         = "${data.terraform_remote_state.vcn.vcn_id}"

  egress_security_rules = [
    {
      destination = "0.0.0.0/0"
      protocol    = "all"
    },
  ]

  ingress_security_rules = [
    {
      source   = "${data.terraform_remote_state.vcn.vcn_cidr}"
      protocol = "6"
    },
    {
      source   = "${data.terraform_remote_state.vcn.vcn_cidr}"
      protocol = "17"
    },
    {
      source   = "${data.terraform_remote_state.vcn.vcn_cidr}"
      protocol = "1"
    }
  ]
}

# Create security list for the worker nodes
# Ingress sources correspond to VCN CIDR
resource "oci_core_security_list" "wn_sec_list" {
  compartment_id = "${var.oci_tenancy_ocid}"
  display_name   = "${data.terraform_remote_state.vcn.env_name}-wn-sec-list"
  vcn_id         = "${data.terraform_remote_state.vcn.vcn_id}"

  egress_security_rules = [
    {
      destination = "0.0.0.0/0"
      protocol    = "all"
    },
  ]

  ingress_security_rules = [
    {
      source   = "${data.terraform_remote_state.vcn.vcn_cidr}"
      protocol = "6"
    },
    {
      source   = "${data.terraform_remote_state.vcn.vcn_cidr}"
      protocol = "17"
    },
    {
      source   = "${data.terraform_remote_state.vcn.vcn_cidr}"
      protocol = "1"
    }
  ]
}

# Create security list for the control plane LB
# Ingress sources correspond to VCN CIDR
resource "oci_core_security_list" "lb_sec_list" {
  compartment_id = "${var.oci_tenancy_ocid}"
  display_name   = "${data.terraform_remote_state.vcn.env_name}-lb-sec-list"
  vcn_id         = "${data.terraform_remote_state.vcn.vcn_id}"

  egress_security_rules = [
    {
      destination = "0.0.0.0/0"
      protocol    = "all"
    },
  ]

  ingress_security_rules = [
    {
      source   = "0.0.0.0/0"
      protocol = "6"
      tcp_options {
        "min" = 6443
        "max" = 6443
      }
    }
  ]
}

output "cp_sec_list_id" {
  value = "${oci_core_security_list.cp_sec_list.id}"
}

output "wn_sec_list_id" {
  value = "${oci_core_security_list.wn_sec_list.id}"
}

output "lb_sec_list_id" {
  value = "${oci_core_security_list.lb_sec_list.id}"
}
