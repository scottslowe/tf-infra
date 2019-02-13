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
  cidr_block          = "${cidrsubnet(data.terraform_remote_state.vcn.vcn_cidr, 8, 1)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  vcn_id              = "${data.terraform_remote_state.vcn.vcn_id}"
  display_name        = "${data.terraform_remote_state.vcn.env_name}-lb-subnet-1"
  dns_label           = "lb1"
  route_table_id      = "${data.terraform_remote_state.vcn.pub_rt_id}"
  security_list_ids   = ["${concat(list(data.terraform_remote_state.sec_lists.lb_sec_list_id, data.terraform_remote_state.vcn.def_sec_list))}"]
}

resource "oci_core_subnet" "subnet_2" {
  compartment_id      = "${var.oci_tenancy_ocid}"
  cidr_block          = "${cidrsubnet(data.terraform_remote_state.vcn.vcn_cidr, 8, 2)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1],"name")}"
  vcn_id              = "${data.terraform_remote_state.vcn.vcn_id}"
  display_name        = "${data.terraform_remote_state.vcn.env_name}-lb-subnet-2"
  dns_label           = "lb2"
  route_table_id      = "${data.terraform_remote_state.vcn.pub_rt_id}"
  security_list_ids   = ["${concat(list(data.terraform_remote_state.sec_lists.lb_sec_list_id, data.terraform_remote_state.vcn.def_sec_list))}"]
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
