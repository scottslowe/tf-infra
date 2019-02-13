# Pull in data about availability domains (ADs) in specified region
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.oci_tenancy_ocid}"
}

# Pull in remote state from control plane subnets
data "terraform_remote_state" "controlplane_subnets" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/controlplane-subnets/terraform.tfstate"
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

# Pull in remote state from control plane load balancer
data "terraform_remote_state" "controlplane_lb" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/cp-loadbalancer/terraform.tfstate"
    region = "us-east-2"
  }
}

# Pull in data on source images
data "oci_core_images" "image_id" {
    compartment_id = "${var.oci_tenancy_ocid}"
    display_name = "${var.oci_image_name}"
}

# Create instances to run etcd
# Create first etcd instance
resource "oci_core_instance" "etcd_instance_1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-etcd-1"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.controlplane_subnets.subnet_1_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-etcd-1-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-etcd-1"
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

# Create Ansible reference for first etcd instance
resource "ansible_host" "etcd_1" {
  inventory_hostname = "${oci_core_instance.etcd_instance_1.private_ip}"
  groups = ["etcd"]
}

# Create second etcd instance
resource "oci_core_instance" "etcd_instance_2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-etcd-2"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.controlplane_subnets.subnet_2_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-etcd-2-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-etcd-2"
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

# Create Ansible reference for second etcd instance
resource "ansible_host" "etcd_2" {
  inventory_hostname = "${oci_core_instance.etcd_instance_2.private_ip}"
  groups = ["etcd"]
}

# Create third etcd instance
resource "oci_core_instance" "etcd_instance_3" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[2],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-etcd-3"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.controlplane_subnets.subnet_3_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-etcd-3-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-etcd-3"
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

# Create Ansible reference for third etcd instance
resource "ansible_host" "etcd_3" {
  inventory_hostname = "${oci_core_instance.etcd_instance_3.private_ip}"
  groups = ["etcd"]
}

# Create first control plane instance
resource "oci_core_instance" "controlplane_instance_1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-controlplane-1"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.controlplane_subnets.subnet_1_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-cp-1-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-controlplane-1"
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

# Create Ansible reference for first control plane instance
resource "ansible_host" "controlplane_1" {
  inventory_hostname = "${oci_core_instance.controlplane_instance_1.private_ip}"
  groups = ["masters"]
}

# Add first control plane node to CP load balancer backend set
resource "oci_load_balancer_backend" "controlplane_be_1" {
  load_balancer_id = "${data.terraform_remote_state.controlplane_lb.loadbalancer_id}"
  backendset_name = "${data.terraform_remote_state.controlplane_lb.backendset_name}"
  ip_address = "${oci_core_instance.controlplane_instance_1.private_ip}"
  port = 6443
}

# Create second control plane instance
resource "oci_core_instance" "controlplane_instance_2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-controlplane-2"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.controlplane_subnets.subnet_2_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-cp-2-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-controlplane-2"
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

# Create Ansible reference for second control plane instance
resource "ansible_host" "controlplane_2" {
  inventory_hostname = "${oci_core_instance.controlplane_instance_2.private_ip}"
  groups = ["masters"]
}

# Add second control plane node to CP load balancer backend set
resource "oci_load_balancer_backend" "controlplane_be_2" {
  load_balancer_id = "${data.terraform_remote_state.controlplane_lb.loadbalancer_id}"
  backendset_name = "${data.terraform_remote_state.controlplane_lb.backendset_name}"
  ip_address = "${oci_core_instance.controlplane_instance_2.private_ip}"
  port = 6443
}

# Create third control plane instance
resource "oci_core_instance" "controlplane_instance_3" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[2],"name")}"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_compute_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-controlplane-3"

  create_vnic_details {
      subnet_id = "${data.terraform_remote_state.controlplane_subnets.subnet_3_id}"
      display_name = "${data.terraform_remote_state.vcn.env_name}-cp-3-vnic"
      hostname_label = "${data.terraform_remote_state.vcn.env_name}-controlplane-3"
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

# Create Ansible reference for third control plane instance
resource "ansible_host" "controlplane_3" {
  inventory_hostname = "${oci_core_instance.controlplane_instance_3.private_ip}"
  groups = ["masters"]
}

# Add third control plane node to CP load balancer backend set
resource "oci_load_balancer_backend" "controlplane_be_3" {
  load_balancer_id = "${data.terraform_remote_state.controlplane_lb.loadbalancer_id}"
  backendset_name = "${data.terraform_remote_state.controlplane_lb.backendset_name}"
  ip_address = "${oci_core_instance.controlplane_instance_3.private_ip}"
  port = 6443
}

# Output details on instances (used to build Ansible inventory)
# Output etcd instance details
output "ansible_host_etcd_1_inventory_hostname" {
  value = "${ansible_host.etcd_1.inventory_hostname}"
}

output "ansible_host_etcd_1_groups" {
  value = "${ansible_host.etcd_1.groups}"
}

output "ansible_host_etcd_2_inventory_hostname" {
  value = "${ansible_host.etcd_2.inventory_hostname}"
}

output "ansible_host_etcd_2_groups" {
  value = "${ansible_host.etcd_2.groups}"
}

output "ansible_host_etcd_3_inventory_hostname" {
  value = "${ansible_host.etcd_3.inventory_hostname}"
}

output "ansible_host_etcd_3_groups" {
  value = "${ansible_host.etcd_3.groups}"
}

# Output control plane instance details
output "ansible_host_controlplane_1_inventory_hostname" {
  value = "${ansible_host.controlplane_1.inventory_hostname}"
}

output "ansible_host_controlplane_1_groups" {
  value = "${ansible_host.controlplane_1.groups}"
}

output "ansible_host_controlplane_2_inventory_hostname" {
  value = "${ansible_host.controlplane_2.inventory_hostname}"
}

output "ansible_host_controlplane_2_groups" {
  value = "${ansible_host.controlplane_2.groups}"
}

output "ansible_host_controlplane_3_inventory_hostname" {
  value = "${ansible_host.controlplane_3.inventory_hostname}"
}

output "ansible_host_controlplane_3_groups" {
  value = "${ansible_host.controlplane_3.groups}"
}
