resource "azurerm_azuread_application" "server_app" {
  name            = "${var.server_app_name}"
  identifier_uris = ["https://${var.server_app_name}"]
  reply_urls      = ["https://${var.server_app_name}"]
}

resource "azurerm_azuread_service_principal" "server_app_sp" {
  application_id = "${azurerm_azuread_application.server_app.application_id}"
}

resource "random_string" "server_app_pass" {
  length           = 32
  special          = true
  override_special = "="
}

resource "azurerm_azuread_service_principal_password" "server_app_pass" {
  service_principal_id = "${azurerm_azuread_service_principal.server_app_sp.id}"
  value                = "${random_string.server_app_pass.result}"
  end_date             = "2020-01-01T01:02:03Z"

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/../../../scripts/aks-aad-delete-client.sh ${var.client_app_name}"
  }
}

data "external" "client_app" {
  program = ["bash", "${path.module}/../../../scripts/aks-aad-create-client.sh"]

  query = {
    client_app_name = "${var.client_app_name}"
  }
}
