terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "iks-test-tfstate"
    key                  = "ikstest/ibm-network.tfstate"
  }
}

provider "ibm" {}

module "network" {
  source            = "../../../modules/network/v1/"
  public_vlan_name  = "${var.public_vlan_name}"
  private_vlan_name = "${var.private_vlan_name}"
  datacenter        = "${var.datacenter}"
  tags              = "${var.tags}"
}
