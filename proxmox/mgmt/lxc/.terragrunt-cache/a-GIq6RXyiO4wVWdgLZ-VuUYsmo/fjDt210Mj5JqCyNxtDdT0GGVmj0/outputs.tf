output "containers" {
  description = "A map of all created containers and their attributes."
  value = { for k, c in proxmox_virtual_environment_container.this : k => {
    id         = c.id
    // CORRECTED: The hostname is found in the 'initialization' block.
    hostname   = c.initialization[0].hostname
    ip_address = c.initialization[0].ip_config[0].ipv4[0].address
  } }
}
# output "shared_root_password" {
#   description = "The single generated password for the root user of all containers in this group."
#   value       = random_password.shared_password.result
#   sensitive   = true
# }

# output "shared_ssh_private_key" {
#   description = "The single generated private SSH key for all containers. This is only populated if no public key was provided."
#   value       = local.generate_shared_ssh_key ? tls_private_key.shared_key[0].private_key_pem : "Not generated. A pre-existing key was used."
#   sensitive   = true
# }

# output "shared_ssh_public_key" {
#   description = "The single public SSH key used for all containers."
#   value       = local.final_ssh_public_key
# }