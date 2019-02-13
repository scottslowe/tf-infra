# Pull in data about availability domains (ADs) in specified region
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.oci_tenancy_ocid}"
}

# Pull in remote state from LB public subnets
data "terraform_remote_state" "lb_subnets" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/lb-subnets/terraform.tfstate"
    region = "us-east-2"
  }
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

# Pull in data on source images
data "oci_core_images" "image_id" {
    compartment_id = "${var.oci_tenancy_ocid}"
    display_name = "${var.oci_image_name}"
}

# Create an instance to serve as an SSH bastion host
resource "oci_core_instance" "bastion_instance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-bastion"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.lb_subnets.subnet_1_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-bastion-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-bastion"
      assign_public_ip = true
  }

  source_details {
      source_id = "${lookup(data.oci_core_images.image_id.images[0], "id")}"
      source_type = "image"
  }

  metadata {
    ssh_authorized_keys = "${file(var.ssh_key)}"
  }
}

# Output details on bastion host
output "bastion_public_ip" {
  value = "${oci_core_instance.bastion_instance.public_ip}"
}
