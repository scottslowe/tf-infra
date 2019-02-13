output "kube_config" {
  value     = "${module.cluster.kube_config}"
  sensitive = true
}

output "host" {
  value = "${module.cluster.host}"
}

output "cluster_name" {
  value = "${module.cluster.cluster_name}"
}

output "aks_resource_group_name" {
  value = "${module.cluster.aks_resource_group_name}"
}
