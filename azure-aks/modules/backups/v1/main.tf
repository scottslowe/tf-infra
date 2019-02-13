data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.aks_cluster_name}"
  resource_group_name = "${var.aks_resource_group_name}"
}

data "azurerm_subscription" "current" {
  subscription_id = "${var.subscription_id}"
}

resource "azurerm_resource_group" "ark_rg" {
  name     = "${var.ark_resource_group_name}"
  location = "${var.location}"

  tags = "${var.common_tags}"
}

resource "azurerm_storage_account" "ark_sa" {
  name                      = "${var.ark_storage_acc_name}"
  resource_group_name       = "${azurerm_resource_group.ark_rg.name}"
  location                  = "${var.location}"
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  enable_https_traffic_only = true

  tags = "${var.common_tags}"
}

resource "azurerm_storage_container" "ark_blob_container" {
  name                  = "${var.ark_blob_container_name}"
  resource_group_name   = "${azurerm_resource_group.ark_rg.name}"
  storage_account_name  = "${azurerm_storage_account.ark_sa.name}"
  container_access_type = "private"
}

resource "azurerm_azuread_application" "ark_application" {
  name = "${var.ark_storage_app_name}"
}

resource "azurerm_azuread_service_principal" "ark_sp" {
  application_id = "${azurerm_azuread_application.ark_application.application_id}"
}

resource "random_string" "ark_sp_password" {
  length           = 32
  special          = true
  override_special = "="
}

resource "azurerm_azuread_service_principal_password" "ark_sp_password" {
  service_principal_id = "${azurerm_azuread_service_principal.ark_sp.id}"
  value                = "${random_string.ark_sp_password.result}"
  end_date             = "${var.password_expiration}"
}

resource "azurerm_role_definition" "ark_sub_role" {
  name        = "${var.aks_cluster_name}-ark-role"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "Subscription scoped role for heptio-ark"

  permissions {
    actions = ["Microsoft.Compute/disks/read",
      "Microsoft.Compute/snapshots/read",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Storage/storageAccounts/read",
    ]

    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}",
  ]
}

resource "azurerm_role_definition" "ark_storage_account_role" {
  name        = "${var.aks_cluster_name}-ark-storage-role"
  scope       = "${azurerm_storage_account.ark_sa.id}"
  description = "Subscription scoped role for heptio-ark"

  permissions {
    actions = ["Microsoft.Storage/storageAccounts/listKeys/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/*",
    ]

    data_actions = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/*"]
    not_actions  = []
  }

  assignable_scopes = [
    "${azurerm_storage_account.ark_sa.id}",
  ]
}

resource "azurerm_role_assignment" "ark_sub_role" {
  scope                = "${data.azurerm_subscription.current.id}"
  role_definition_id =  "${azurerm_role_definition.ark_sub_role.id}"
  principal_id         = "${azurerm_azuread_service_principal.ark_sp.id}"
}

resource "azurerm_role_assignment" "ark_storage_account_role" {
  scope                = "${azurerm_storage_account.ark_sa.id}"
  role_definition_id =  "${azurerm_role_definition.ark_storage_account_role.id}"
  principal_id         = "${azurerm_azuread_service_principal.ark_sp.id}"
}

data "template_file" "ark_secret" {
  template = "${file("${path.module}/templates/ark_secret.yml.tpl")}"

  vars {
    AZURE_CLIENT_ID       = "${base64encode(azurerm_azuread_service_principal.ark_sp.application_id)}"
    AZURE_CLIENT_SECRET   = "${base64encode(random_string.ark_sp_password.result)}"
    AZURE_RESOURCE_GROUP  = "${base64encode(data.azurerm_kubernetes_cluster.aks_cluster.node_resource_group)}"
    AZURE_SUBSCRIPTION_ID = "${base64encode(var.subscription_id)}"
    AZURE_TENANT_ID       = "${base64encode(var.tenant_id)}"
  }
}

data "template_file" "ark_backup_storage_location" {
  template = "${file("${path.module}/templates/ark_backup_storage_location.yml.tpl")}"

  vars {
    ark_blob_container_name  = "${azurerm_storage_container.ark_blob_container.name}"
    ark_resource_group_name  = "${azurerm_resource_group.ark_rg.name}"
    ark_storage_account_name = "${azurerm_storage_account.ark_sa.name}"
  }
}

resource "local_file" "ark_secret" {
  content  = "${data.template_file.ark_secret.rendered}"
  filename = "${path.root}/../../../../../k8s/spec/azure/clusters/${var.codebase_cluster_name}/applications/ark/secret.yml"
}

resource "local_file" "ark_backup_storage_location" {
  content  = "${data.template_file.ark_backup_storage_location.rendered}"
  filename = "${path.root}/../../../../../k8s/spec/azure/clusters/${var.codebase_cluster_name}/applications/ark/backupstoragelocation.yml"
}
