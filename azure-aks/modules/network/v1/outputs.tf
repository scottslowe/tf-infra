output "vnet_name" {
  value = "${azurerm_virtual_network.aks_vnet.name}"
}

output "vnet_subnet_name" {
  value = "${azurerm_subnet.aks_subnet.name}"
}

output "vnet_subnet_id" {
  value = "${azurerm_subnet.aks_subnet.id}"
}

output "vnet_resource_group_name" {
  value = "${azurerm_resource_group.k8s.name}"
}
