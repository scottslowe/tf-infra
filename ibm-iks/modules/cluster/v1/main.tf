resource "ibm_container_cluster" "k8s_cluster" {
  name            = "${var.cluster_name}"
  datacenter      = "${var.datacenter}"
  machine_type    = "${var.machine_type}"
  hardware        = "shared"
  public_vlan_id  = "${var.public_vlan_id}"
  private_vlan_id = "${var.private_vlan_id}"
  region          = "${var.region}"

  default_pool_size = "${var.default_pool_size}"

  #webhook = [{
  #  level = "Normal"
  #  type  = "slack"

    # Cuurently messages are only sent when new node is added see: 
    # https://github.com/IBM-Cloud/terraform-provider-ibm/issues/228
  #  url = "${var.slack_api_webhook}"
  #}]
}
