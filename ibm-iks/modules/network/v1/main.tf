resource "ibm_network_vlan" "vlan_public" {
  name       = "${var.public_vlan_name}"
  datacenter = "${var.datacenter}"
  type       = "PUBLIC"
  tags       = "${var.tags}"
}

resource "ibm_network_vlan" "vlan_private" {
  name       = "${var.private_vlan_name}"
  datacenter = "${var.datacenter}"
  type       = "PRIVATE"
  tags       = "${var.tags}"
}

# resource "ibm_subnet" "portable_subnet_public" {
#   type = "Portable"
#   private = false
#   ip_version = 4
#   capacity = 64
#   vlan_id = "${ibm_network_vlan.vlan_public.id}"
#   notes = "portable_subnet"
#   //User can increase timeouts 
#   timeouts {
#     create = "45m"
#   }
# }


# resource "ibm_subnet" "portable_subnet_private" {
#   type = "Portable"
#   private = true
#   ip_version = 4
#   capacity = 64
#   vlan_id = "${ibm_network_vlan.vlan_private.id}"
#   notes = "portable_subnet"
#   //User can increase timeouts 
#   timeouts {
#     create = "45m"
#   }
# }

