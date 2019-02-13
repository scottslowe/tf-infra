# Pull in remote state from VCN
data "terraform_remote_state" "vcn" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/vcn/terraform.tfstate"
    region = "us-east-2"
  }
}

# Pull in remote state from control plane LB
data "terraform_remote_state" "controlplane_lb" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/cp-loadbalancer/terraform.tfstate"
    region = "us-east-2"
  }
}

# Pull in remote state from LB subnets
data "terraform_remote_state" "lb_subnets" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/lb-subnets/terraform.tfstate"
    region = "us-east-2"
  }
}

# Set up the necessary elements for the OCI cloud controller manager (CCM)
resource "tls_private_key" "cloud_controller_user_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_group" "cloud_controller_group" {
  name = "${data.terraform_remote_state.vcn.env_name}_cloud_controller_group"
  description = "Terraform created group for OCI Cloud Controller Manager"
}

resource "oci_identity_user" "cloud_controller_user" {
  name = "${data.terraform_remote_state.vcn.env_name}_cloud_controller_user"
  description = "Terraform created user for OCI Cloud Controller Manager"
}

resource "oci_identity_api_key" "cloud_controller_key_assoc" {
  user_id = "${oci_identity_user.cloud_controller_user.id}"
  key_value = "${tls_private_key.cloud_controller_user_key.public_key_pem}"
}

resource "oci_identity_user_group_membership" "cloud_controller_user_group_assoc" {
  compartment_id = "${var.oci_tenancy_ocid}"
  user_id = "${oci_identity_user.cloud_controller_user.id}"
  group_id = "${oci_identity_group.cloud_controller_group.id}"
}

resource "oci_identity_policy" "cloud_controller_policy" {
  depends_on = ["oci_identity_group.cloud_controller_group"]
  compartment_id = "${var.oci_tenancy_ocid}"
  name = "${data.terraform_remote_state.vcn.env_name}_cloud_controller_policy"
  description = "${data.terraform_remote_state.vcn.env_name}_cloud_controller_group policy"
  statements = [
    "Allow group id ${oci_identity_group.cloud_controller_group.id} to manage load-balancers in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.cloud_controller_group.id} to manage security-lists in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.cloud_controller_group.id} to read instances in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.cloud_controller_group.id} to read subnets in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.cloud_controller_group.id} to read vnics in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.cloud_controller_group.id} to read vnic-attachments in compartment id ${var.oci_tenancy_ocid}",
  ]
}

# Set up the necessary elements for the OCI FlexVolume driver
resource "tls_private_key" "flexvolume_driver_user_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_group" "flexvolume_driver_group" {
  name = "${data.terraform_remote_state.vcn.env_name}_flexvolume_driver_group"
  description = "Terraform created group for OCI Cloud Controller Manager"
}

resource "oci_identity_user" "flexvolume_driver_user" {
  name = "${data.terraform_remote_state.vcn.env_name}_flexvolume_driver_user"
  description = "Terraform created user for OCI Cloud Controller Manager"
}

resource "oci_identity_api_key" "flexvolume_driver_key_assoc" {
  user_id = "${oci_identity_user.flexvolume_driver_user.id}"
  key_value = "${tls_private_key.flexvolume_driver_user_key.public_key_pem}"
}

resource "oci_identity_user_group_membership" "flexvolume_driver_user_group_assoc" {
  compartment_id = "${var.oci_tenancy_ocid}"
  user_id = "${oci_identity_user.flexvolume_driver_user.id}"
  group_id = "${oci_identity_group.flexvolume_driver_group.id}"
}

resource "oci_identity_policy" "flexvolume_driver_policy" {
  depends_on = ["oci_identity_group.flexvolume_driver_group"]
  compartment_id = "${var.oci_tenancy_ocid}"
  name = "${data.terraform_remote_state.vcn.env_name}_flexvolume_driver_policy"
  description = "${data.terraform_remote_state.vcn.env_name}_flexvolume_driver_group policy"
  statements = [
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to read vnic-attachments in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to read vnics in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to read instances in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to read subnets in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to use volumes in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to use instances in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to manage volume-attachments in compartment id ${var.oci_tenancy_ocid}",

    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to read file-systems in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to read mount-targets in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to read private-ips in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.flexvolume_driver_group.id} to manage export-sets in compartment id ${var.oci_tenancy_ocid}",
  ]
}

# Set up the necessary elements for the volume provisioner user
resource "tls_private_key" "volume_provisioner_user_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_group" "volume_provisioner_group" {
  name = "${data.terraform_remote_state.vcn.env_name}_volume_provisioner_group"
  description = "Terraform created group for OCI Cloud Controller Manager"
}

resource "oci_identity_user" "volume_provisioner_user" {
  name = "${data.terraform_remote_state.vcn.env_name}_volume_provisioner_user"
  description = "Terraform created user for OCI Cloud Controller Manager"
}

resource "oci_identity_api_key" "volume_provisioner_key_assoc" {
  user_id = "${oci_identity_user.volume_provisioner_user.id}"
  key_value = "${tls_private_key.volume_provisioner_user_key.public_key_pem}"
}

resource "oci_identity_user_group_membership" "volume_provisioner_user_group_assoc" {
  compartment_id = "${var.oci_tenancy_ocid}"
  user_id = "${oci_identity_user.volume_provisioner_user.id}"
  group_id = "${oci_identity_group.volume_provisioner_group.id}"
}

resource "oci_identity_policy" "volume_provisioner_policy" {
  depends_on = ["oci_identity_group.volume_provisioner_group"]
  compartment_id = "${var.oci_tenancy_ocid}"
  name = "${data.terraform_remote_state.vcn.env_name}_volume_provisioner_policy"
  description = "${data.terraform_remote_state.vcn.env_name}_volume_provisioner_group policy"
  statements = [
    "Allow group id ${oci_identity_group.volume_provisioner_group.id} to manage volumes in compartment id ${var.oci_tenancy_ocid}",
    "Allow group id ${oci_identity_group.volume_provisioner_group.id} to manage file-systems in compartment id ${var.oci_tenancy_ocid}",
  ]
}

# Generate configuration file and private key file for cloud controller manager
data "template_file" "ccm_cfg_template" {
  template = "${file("${path.module}/cloud-provider.yaml.tpl")}"

  vars {
    tenancy_ocid = "${var.oci_tenancy_ocid}"
    user_ocid = "${oci_identity_user.cloud_controller_user.id}"
    auth_key = "${tls_private_key.cloud_controller_user_key.private_key_pem}"
    vcn_id = "${data.terraform_remote_state.vcn.vcn_id}"
    lb_subnet1 = "${data.terraform_remote_state.lb_subnets.subnet_1_id}"
    lb_subnet2 = "${data.terraform_remote_state.lb_subnets.subnet_2_id}"
  }
}

resource "local_file" "ccm_config" {
  content = "${data.template_file.ccm_cfg_template.rendered}"
  filename = "${path.module}/cloud-provider.yaml"
}

resource "local_file" "ccm_private_key" {
  content = "${tls_private_key.cloud_controller_user_key.private_key_pem}"
  filename = "${path.module}/ccm-private-key.pem"
}

# Generate configuration file and private key file for FlexVolume driver
data "template_file" "flexvol_cfg_template" {
  template = "${file("${path.module}/flexvolume.yaml.tpl")}"

  vars {
    tenancy_ocid = "${var.oci_tenancy_ocid}"
    user_ocid = "${oci_identity_user.flexvolume_driver_user.id}"
    auth_key = "${tls_private_key.flexvolume_driver_user_key.private_key_pem}"
    vcn_id = "${data.terraform_remote_state.vcn.vcn_id}"
  }
}

resource "local_file" "flexvol_config" {
  content = "${data.template_file.flexvol_cfg_template.rendered}"
  filename = "${path.module}/flexvolume.yaml"
}

resource "local_file" "flexvol_private_key" {
  content = "${tls_private_key.flexvolume_driver_user_key.private_key_pem}"
  filename = "${path.module}/flexvol-private-key.pem"
}

# Generate configuration file and private key file for volume provisioner
data "template_file" "volprov_cfg_template" {
  template = "${file("${path.module}/volumeprovisioner.yaml.tpl")}"

  vars {
    tenancy_ocid = "${var.oci_tenancy_ocid}"
    user_ocid = "${oci_identity_user.volume_provisioner_user.id}"
    auth_key = "${tls_private_key.volume_provisioner_user_key.private_key_pem}"
  }
}

resource "local_file" "volprov_config" {
  content = "${data.template_file.volprov_cfg_template.rendered}"
  filename = "${path.module}/volumeprovisioner.yaml"
}

resource "local_file" "volprov_private_key" {
  content = "${tls_private_key.volume_provisioner_user_key.private_key_pem}"
  filename = "${path.module}/volprov-private-key.pem"
}
