terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "iks-test-tfstate"
    key                  = "ikstest/ibm-cluster.tfstate"
  }
}

provider "ibm" {}

data "terraform_remote_state" "ibm_network" {
  backend = "azurerm"

  config {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "iks-test-tfstate"
    key                  = "ikstest/ibm-network.tfstate"
  }
}

module "cluster" {
  source            = "../../../modules/cluster/v1/"
  public_vlan_id    = "${data.terraform_remote_state.ibm_network.public_vlan_id}"
  private_vlan_id   = "${data.terraform_remote_state.ibm_network.private_vlan_id}"
  datacenter        = "${var.datacenter}"
  cluster_name      = "${var.cluster_name}"
  region            = "${var.region}"
  datacenter        = "${var.datacenter}"
  machine_type      = "${var.machine_type}"
  slack_api_webhook = "${var.slack_api_webhook}"
  default_pool_size = "${var.default_pool_size}"
}
