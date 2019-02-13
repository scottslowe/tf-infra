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

resource "azurerm_azuread_application" "k8s_app" {
  name = "${var.environment_name}-aks-cluster"
}

resource "azurerm_azuread_service_principal" "k8s_sp" {
  application_id = "${azurerm_azuread_application.k8s_app.application_id}"
}

resource "random_string" "k8s_sp_password" {
  length           = 32
  special          = true
  override_special = "="
}

resource "azurerm_azuread_service_principal_password" "k8s_sp_pass" {
  service_principal_id = "${azurerm_azuread_service_principal.k8s_sp.id}"
  value                = "${random_string.k8s_sp_password.result}"
  end_date             = "${var.password_expiration}"
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = "${data.azurerm_subnet.aks_subnet.id}"
  role_definition_name = "Network Contributor"
  principal_id         = "${azurerm_azuread_service_principal.k8s_sp.id}"
}

resource "azurerm_role_assignment" "acr_reader" {
  scope                = "/subscriptions/${var.registry_subscription_id}/resourceGroups/${var.registry_resource_group}/providers/Microsoft.ContainerRegistry/registries/${var.registry_name}"
  role_definition_name = "Reader"
  principal_id         = "${azurerm_azuread_service_principal.k8s_sp.id}"
}
