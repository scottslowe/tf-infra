terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "tfstate-backend"
    key                  = "akstest/aks-security.tfstate"
  }
}

provider "azurerm" {
  version = "~> 1.19.0"
}

data "terraform_remote_state" "aks_network" {
  backend = "azurerm"

  config {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "tfstate-backend"
    key                  = "akstest/aks-network.tfstate"
  }
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

module "security" {
  source                   = "../../../modules/security/v1/"
  environment_name         = "${var.environment_name}"
  vnet_name                = "${data.terraform_remote_state.aks_network.vnet_name}"
  vnet_resource_group_name = "${data.terraform_remote_state.aks_network.vnet_resource_group_name}"
  subnet_name              = "${data.terraform_remote_state.aks_network.vnet_subnet_name}"
  registry_resource_group  = "${var.registry_resource_group}"
  registry_name            = "${var.registry_name}"
  registry_subscription_id = "${var.registry_subscription_id}"
}

# This will be manaully created for now
# module "aad" {
#   source          = "../../../modules/aad/v1/"
#   server_app_name = "${var.server_app_name}"
#   client_app_name = "${var.client_app_name}"
# }

