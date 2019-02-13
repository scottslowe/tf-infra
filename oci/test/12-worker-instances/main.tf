# Pull in data about availability domains (ADs) in specified region
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.oci_tenancy_ocid}"
}

# Pull in remote state from worker subnets
data "terraform_remote_state" "worker_subnets" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/worker-subnets/terraform.tfstate"
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

# Create instances to serve as Kubernetes worker nodes
# Create first worker node
resource "oci_core_instance" "worker_instance_1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-worker-1"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.worker_subnets.subnet_1_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-worker-1-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-worker-1"
      assign_public_ip = false
  }

  source_details {
      source_id = "${lookup(data.oci_core_images.image_id.images[0], "id")}"
      source_type = "image"
  }

  metadata {
    ssh_authorized_keys = "${file(var.ssh_key)}"
  }
}

# Create Ansible reference for first worker node
resource "ansible_host" "worker_1" {
  inventory_hostname = "${oci_core_instance.worker_instance_1.private_ip}"
  groups = ["workers"]
}

# Create second worker node
resource "oci_core_instance" "worker_instance_2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-worker-2"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.worker_subnets.subnet_2_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-worker-2-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-worker-2"
      assign_public_ip = false
  }

  source_details {
      source_id = "${lookup(data.oci_core_images.image_id.images[0], "id")}"
      source_type = "image"
  }

  metadata {
    ssh_authorized_keys = "${file(var.ssh_key)}"
  }
}

# Create Ansible reference for second worker node
resource "ansible_host" "worker_2" {
  inventory_hostname = "${oci_core_instance.worker_instance_2.private_ip}"
  groups = ["workers"]
}

# Create third worker node
resource "oci_core_instance" "worker_instance_3" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[2],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-worker-3"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.worker_subnets.subnet_3_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-worker-3-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-worker-3"
      assign_public_ip = false
  }

  source_details {
      source_id = "${lookup(data.oci_core_images.image_id.images[0], "id")}"
      source_type = "image"
  }

  metadata {
    ssh_authorized_keys = "${file(var.ssh_key)}"
  }
}

# Create Ansible reference for third worker node
resource "ansible_host" "worker_3" {
  inventory_hostname = "${oci_core_instance.worker_instance_3.private_ip}"
  groups = ["workers"]
}

# Can add additional worker nodes here
# For each worker node, two resources are needed:
# 1. An "oci_core_instance" resource
# 2. An "ansible_host" resource
# You can model these resources after the existing resources above
# You must also create an output of the ansible_host items attributes
# This is necessary to build a consolidated Ansible inventory
# Use the outputs below as a template

# Output details on instances (used to build Ansible inventory)
# Output worker node details
output "ansible_host_worker_1_inventory_hostname" {
  value = "${ansible_host.worker_1.inventory_hostname}"
}

output "ansible_host_worker_1_groups" {
  value = "${ansible_host.worker_1.groups}"
}

output "ansible_host_worker_2_inventory_hostname" {
  value = "${ansible_host.worker_2.inventory_hostname}"
}

output "ansible_host_worker_2_groups" {
  value = "${ansible_host.worker_2.groups}"
}

output "ansible_host_worker_3_inventory_hostname" {
  value = "${ansible_host.worker_3.inventory_hostname}"
}

output "ansible_host_worker_3_groups" {
  value = "${ansible_host.worker_3.groups}"
}
