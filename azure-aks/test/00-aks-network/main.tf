terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "tfstate-backend"
    key                  = "akstest/aks-network.tfstate"
  }
}

provider "azurerm" {
  version = "~> 1.19.0"
}

/* 
Creating Tags like this does two things:
1) It merges in vars defined in the env (var.env_vars) with values created here
2) By creating local values and then mapping over them we are able to create 
key:value pairs that are dependant on other vars and we are able to create
"dynamic keys" for example:
  "kaiserpermanente-${var.environment_name}" 
  will be rendered as the key
  "kaiserpermanente-akstest" 
*/
locals {
  common_tags = "${merge(
    var.tags,
    map(
        "key", "value",
        "kaiserpermanente-${var.environment_name}", "${var.environment_name}",
        "kaiserpermanente-provisioner", "terraform",
        "kaiserpermanente-provisioner-cluster-name", "${var.cluster_name}"
    )
)}"
}

module "network" {
  source                   = "../../../modules/network/v1/"
  common_tags              = "${local.common_tags}"
  cluster_name             = "${var.cluster_name}"
  location                 = "${var.location}"
  vnet_name                = "${var.vnet_name}"
  subnet_name              = "${var.subnet_name}"
  subnet_address_prefix    = "${var.subnet_address_prefix}"
  vnet_address_space       = "${var.vnet_address_space}"
  vnet_dns_servers         = "${var.vnet_dns_servers}"
  vnet_resource_group_name = "${var.vnet_resource_group_name}"
}
