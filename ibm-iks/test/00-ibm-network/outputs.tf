output "public_vlan_id" {
  value = "${module.network.public_vlan_id}"
}

output "private_vlan_id" {
  value = "${module.network.private_vlan_id}"
}
