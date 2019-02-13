resource "azurerm_resource_group" "k8s" {
  name     = "${var.vnet_resource_group_name}"
  location = "${var.location}"

  tags = "${var.common_tags}"
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.vnet_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  address_space       = "${var.vnet_address_space}"
  dns_servers         = "${var.vnet_dns_servers}"
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${azurerm_resource_group.k8s.name}"
  address_prefix       = "${var.subnet_address_prefix}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}"
}

#TODO implement Vnet Peering

