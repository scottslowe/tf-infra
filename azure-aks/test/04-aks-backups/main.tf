terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "tfstate-backend"
    key                  = "akstest/aks-backups.tfstate"
  }
}

provider "azurerm" {
  version = "~> 1.19.0"
}

data "terraform_remote_state" "aks_cluster" {
  backend = "azurerm"

  config {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "tfstate-backend"
    key                  = "akstest/aks-cluster.tfstate"
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
  "kaiserpermanente-aktest" 
*/
locals {
  common_tags = "${merge(
    var.tags,
    map(
        "key", "value",
        "kaiserpermanente-${var.environment_name}", "${var.environment_name}",
        "kaiserpermanente-provisioner", "terraform",
        "kaiserpermanente-provisioner-cluster-name", "${data.terraform_remote_state.aks_cluster.cluster_name}"
    )
)}"
}

module "backups" {
  source                  = "../../../modules/backups/v1/"
  common_tags             = "${local.common_tags}"
  aks_resource_group_name = "${data.terraform_remote_state.aks_cluster.aks_resource_group_name}"
  aks_cluster_name        = "${data.terraform_remote_state.aks_cluster.cluster_name}"
  codebase_cluster_name   = "${var.codebase_cluster_name}"
  subscription_id         = "${var.subscription_id}"
  tenant_id               = "${var.tenant_id}"
  ark_resource_group_name = "${var.ark_resource_group_name}"
  location                = "${var.location}"
  ark_storage_acc_name    = "${var.ark_storage_acc_name}"
  ark_blob_container_name = "${var.ark_blob_container_name}"
  ark_storage_app_name    = "${var.ark_storage_app_name}"
}
