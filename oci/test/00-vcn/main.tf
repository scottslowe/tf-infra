resource "oci_core_vcn" "vcn" {
  cidr_block     = "${var.vcn_cidr_block}"
  compartment_id = "${var.oci_tenancy_ocid}"
  dns_label      = "${var.name}"
  display_name   = "${var.name}-vcn"
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = "${var.oci_tenancy_ocid}"
  vcn_id         = "${oci_core_vcn.vcn.id}"
  display_name   = "${var.name}-ig"
}

resource "oci_core_nat_gateway" "natgw" {
  compartment_id = "${var.oci_tenancy_ocid}"
  vcn_id = "${oci_core_vcn.vcn.id}"
  display_name = "${var.name}-natgw"
  block_traffic = false
}

resource "oci_core_route_table" "pub_rt" {
  compartment_id = "${var.oci_tenancy_ocid}"
  vcn_id         = "${oci_core_vcn.vcn.id}"
  display_name   = "${var.name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.ig.id}"
  }
}

resource "oci_core_route_table" "priv_rt" {
  compartment_id = "${var.oci_tenancy_ocid}"
  vcn_id         = "${oci_core_vcn.vcn.id}"
  display_name   = "${var.name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_nat_gateway.natgw.id}"
  }
}

output "vcn_id" {
  value = "${oci_core_vcn.vcn.id}"
}

output "vcn_cidr" {
  value = "${var.vcn_cidr_block}"
}

output "env_name" {
  value = "${var.name}"
}

output "ig_id" {
  value = "${oci_core_internet_gateway.ig.id}"
}

output "natgw_id" {
  value = "${oci_core_nat_gateway.natgw.id}"
}

output "pub_rt_id" {
  value = "${oci_core_route_table.pub_rt.id}"
}

output "priv_rt_id" {
  value = "${oci_core_route_table.priv_rt.id}"
}

output "def_sec_list" {
  value = "${oci_core_vcn.vcn.default_security_list_id}"
}
