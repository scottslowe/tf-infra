output "client_id" {
  value = "${module.security.client_id}"
}

output "client_secret" {
  value     = "${module.security.client_secret}"
  sensitive = true
}

output "client_sp_id" {
  value = "${module.security.client_sp_id}"
}

# This will be manually created for now
# output "aad_client_id" {
#   value = "${module.aad.client_id}"
# }


# output "aad_server_id" {
#   value = "${module.aad.server_id}"
# }


# output "aad_server_secret" {
#   value     = "${module.aad.server_secret}"
#   sensitive = true
# }

