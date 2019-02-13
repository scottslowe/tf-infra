output "public_vlan_id" {
  value = "${ibm_network_vlan.vlan_public.id}"
}

output "private_vlan_id" {
  value = "${ibm_network_vlan.vlan_private.id}"
}
