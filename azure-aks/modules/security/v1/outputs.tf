output "client_id" {
  value = "${azurerm_azuread_service_principal.k8s_sp.application_id}"
}

output "client_secret" {
  value = "${random_string.k8s_sp_password.result}"
}

output "client_sp_id" {
  value = "${azurerm_azuread_service_principal.k8s_sp.id}"
}
