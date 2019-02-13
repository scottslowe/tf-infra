output "client_id" {
  value = "${data.external.client_app.result["client_app_id"]}"
}

output "server_id" {
  value = "${azurerm_azuread_application.server_app.application_id}"
}

output "server_secret" {
  value     = "${random_string.server_app_pass.result}"
  sensitive = true
}
