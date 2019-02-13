data "terraform_remote_state" "lb_subnets" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/lb-subnets/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "vcn" {
  backend = "s3"

  config {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/vcn/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "oci_load_balancer" "loadbalancer" {
  count = "${var.cp_is_ha == "true" ? 1 : 0 }"
  compartment_id = "${var.oci_tenancy_ocid}"
  shape = "${var.oci_lb_shape}"
  display_name = "${data.terraform_remote_state.vcn.env_name}-cp-loadbalancer"
  subnet_ids = ["${compact(list(data.terraform_remote_state.lb_subnets.subnet_1_id,data.terraform_remote_state.lb_subnets.subnet_2_id))}"]
}

resource "oci_load_balancer_backendset" "lb_backendset" {
  count = "${var.cp_is_ha == "true" ? 1 : 0 }"
  name = "${data.terraform_remote_state.vcn.env_name}-cp-backendset"
  load_balancer_id = "${oci_load_balancer.loadbalancer.id}"
  policy = "ROUND_ROBIN"

  health_checker {
    port = "${var.cp_port}"
    protocol = "TCP"
    response_body_regex = ".*"
  }  
}

resource "oci_load_balancer_listener" "lb_listener" {
  count = "${var.cp_is_ha == "true" ? 1 : 0 }"
  load_balancer_id = "${oci_load_balancer.loadbalancer.id}"
  name = "${data.terraform_remote_state.vcn.env_name}-cp-listener"
  default_backend_set_name = "${oci_load_balancer_backendset.lb_backendset.name}"
  port = "${var.cp_port}"
  protocol = "TCP"
}

output "loadbalancer_id" {
  value = "${oci_load_balancer.loadbalancer.0.id}"
}

output "backendset_name" {
  value = "${oci_load_balancer_backendset.lb_backendset.0.name}"
}
