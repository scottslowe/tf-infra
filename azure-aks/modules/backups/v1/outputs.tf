output "ark_sp_client_id" {
  value = "${azurerm_azuread_service_principal.ark_sp.application_id}"
}
