data "local_file" "ssh_public_key" {
  filename = "${var.ssh_public_key}"
}

data "azurerm_resource_group" "vnet_rg" {
  name = "${var.vnet_resource_group_name}"
}

data "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${data.azurerm_resource_group.vnet_rg.name}"
}

data "azurerm_subnet" "aks_subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${data.azurerm_virtual_network.aks_vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.vnet_rg.name}"
}

resource "azurerm_resource_group" "k8s_rg" {
  name     = "${var.aks_resource_group_name}"
  location = "${var.location}"

  tags = "${var.common_tags}"
}

resource "azurerm_role_assignment" "storage_contributor" {
  scope                = "${azurerm_resource_group.k8s_rg.id}"
  role_definition_name = "Storage Account Contributor"
  principal_id         = "${var.client_sp_id}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.k8s_rg.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.k8s_version}"

  tags = "${var.common_tags}"

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = "${var.os_disk_size_gb}"
    max_pods        = "${var.max_pods_per_node}"
    vnet_subnet_id  = "${data.azurerm_subnet.aks_subnet.id}"
  }

  linux_profile {
    admin_username = "deploy"

    ssh_key {
      key_data = "${data.local_file.ssh_public_key.content}"
    }
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  role_based_access_control {
    azure_active_directory {
      client_app_id     = "${var.aad_client_id}"
      server_app_id     = "${var.aad_server_id}"
      server_app_secret = "${var.aad_server_secret}"
    }
  }

  network_profile {
    network_plugin = "azure"
  }
}

/* 
UnComment out below if you wish to create cluster with aad integration
*/
# data "external" "k8s" {
#   program = ["bash", "${path.module}/../../../scripts/aks-cluster-create.sh"]


#   query = {
#     cluster_name    = "${var.cluster_name}"
#     resource_group  = "${azurerm_resource_group.k8s_rg.name}"
#     location        = "${var.location}"
#     dns_prefix      = "${var.dns_prefix}"
#     k8s_version     = "${var.k8s_version}"
#     agent_count     = "${var.agent_count}"
#     vm_size         = "${var.vm_size}"
#     os_disk_size_gb = "${var.os_disk_size_gb}"
#     max_pods        = "${var.max_pods_per_node}"
#     subnet_id       = "${data.azurerm_subnet.aks_subnet.id}"
#     admin_username  = "deploy"
#     key_data        = "${data.local_file.ssh_public_key.content}"
#     client_id       = "${var.client_id}"
#     client_secret   = "${var.client_secret}"
#   }
# }

