terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "tfstate-backend"
    key                  = "akstest/aks-cluster.tfstate"
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

data "terraform_remote_state" "aks_security" {
  backend = "azurerm"

  config {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfbackendacct"
    container_name       = "tfstate-backend"
    key                  = "akstest/aks-security.tfstate"
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

module "cluster" {
  source                   = "../../../modules/cluster/v1/"
  common_tags              = "${local.common_tags}"
  vnet_name                = "${data.terraform_remote_state.aks_network.vnet_name}"
  vnet_resource_group_name = "${data.terraform_remote_state.aks_network.vnet_resource_group_name}"
  subnet_name              = "${data.terraform_remote_state.aks_network.vnet_subnet_name}"
  client_id                = "${data.terraform_remote_state.aks_security.client_id}"
  client_secret            = "${data.terraform_remote_state.aks_security.client_secret}"
  client_sp_id             = "${data.terraform_remote_state.aks_security.client_sp_id}"

  aad_client_id           = "${var.aad_client_id}"
  aad_server_id           = "${var.aad_server_id}"
  aad_server_secret       = "${var.aad_server_secret}"
  aks_resource_group_name = "${var.aks_resource_group_name}"
  cluster_name            = "${var.cluster_name}"
  dns_prefix              = "${var.dns_prefix}"
  location                = "${var.location}"
  agent_count             = "${var.agent_count}"
  ssh_public_key          = "${var.ssh_public_key}"
  k8s_version             = "${var.k8s_version}"
  vm_size                 = "${var.vm_size}"
  os_disk_size_gb         = "${var.os_disk_size_gb}"
}
