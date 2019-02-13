# Pull in data about availability domains (ADs) in specified region
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.oci_tenancy_ocid}"
}

# Pull in remote state from VCN
data "terraform_remote_state" "vcn" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/vcn/terraform.tfstate"
    region = "us-east-2"
  }
}

# Pull in remote state from security lists
data "terraform_remote_state" "sec_lists" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/securitylists/terraform.tfstate"
    region = "us-east-2"
  }
}

# Create a subnet in each AD
resource "oci_core_subnet" "subnet_1" {
  compartment_id      = "${var.oci_tenancy_ocid}"
  cidr_block          = "${cidrsubnet(data.terraform_remote_state.vcn.vcn_cidr, 8, 6)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  vcn_id              = "${data.terraform_remote_state.vcn.vcn_id}"
  display_name        = "${data.terraform_remote_state.vcn.env_name}-wn-subnet-1"
  dns_label           = "wn1"
  route_table_id      = "${data.terraform_remote_state.vcn.priv_rt_id}"
  security_list_ids   = ["${concat(list(data.terraform_remote_state.sec_lists.wn_sec_list_id))}"]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "subnet_2" {
  compartment_id      = "${var.oci_tenancy_ocid}"
  cidr_block          = "${cidrsubnet(data.terraform_remote_state.vcn.vcn_cidr, 8, 7)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1],"name")}"
  vcn_id              = "${data.terraform_remote_state.vcn.vcn_id}"
  display_name        = "${data.terraform_remote_state.vcn.env_name}-wn-subnet-2"
  dns_label           = "wn2"
  route_table_id      = "${data.terraform_remote_state.vcn.priv_rt_id}"
  security_list_ids   = ["${concat(list(data.terraform_remote_state.sec_lists.wn_sec_list_id))}"]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "subnet_3" {
  compartment_id      = "${var.oci_tenancy_ocid}"
  cidr_block          = "${cidrsubnet(data.terraform_remote_state.vcn.vcn_cidr, 8, 8)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[2],"name")}"
  vcn_id              = "${data.terraform_remote_state.vcn.vcn_id}"
  display_name        = "${data.terraform_remote_state.vcn.env_name}-wn-subnet-3"
  dns_label           = "wn3"
  route_table_id      = "${data.terraform_remote_state.vcn.priv_rt_id}"
  security_list_ids   = ["${concat(list(data.terraform_remote_state.sec_lists.wn_sec_list_id))}"]
  prohibit_public_ip_on_vnic = true
}

output "subnet_1_id" {
  value = "${oci_core_subnet.subnet_1.id}"
}

output "subnet_1_cidr_block" {
  value = "${oci_core_subnet.subnet_1.cidr_block}"
}

output "subnet_2_id" {
  value = "${oci_core_subnet.subnet_2.id}"
}

output "subnet_2_cidr_block" {
  value = "${oci_core_subnet.subnet_2.cidr_block}"
}

output "subnet_3_id" {
  value = "${oci_core_subnet.subnet_3.id}"
}

output "subnet_3_cidr_block" {
  value = "${oci_core_subnet.subnet_3.cidr_block}"
}
