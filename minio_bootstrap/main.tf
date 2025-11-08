// File: main.tf
//
// This file defines the MinIO LXC container. It will use a local state file
// in this directory called 'terraform.tfstate'.



// Configure the Proxmox provider using the variables.
// FIX #1: Reverted to the correct nested provider configuration.


locals {
  // Check if the user provided an SSH key.
  generate_new_ssh_key = var.ssh_public_key == ""

  // Use the user's key if provided, otherwise use the generated key.
  final_ssh_public_key = local.generate_new_ssh_key ? tls_private_key.container_key[0].public_key_openssh : var.ssh_public_key
}

resource "random_password" "container_password" {
  length  = 24
  special = true
}

// Only generate a new SSH key if one was not provided.
resource "tls_private_key" "container_key" {
  count     = local.generate_new_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}


// Define and create the MinIO LXC container.
resource "proxmox_virtual_environment_container" "minio_server" {
  node_name   = var.node_name
  vm_id       = var.vm_id
  pool_id     = var.pool_id
  description = "MinIO S3 Server - Bootstrapped with OpenTofu"
  unprivileged = var.unprivileged

  operating_system {
    template_file_id = var.os_template_file_id
    type             = "debian"
  }

  disk {
    datastore_id = "ceph"
    size         = 10
  }

#   // Add a second, larger disk for the S3 data.
#   mount_point {
#     path   = "/mnt/data"
#     size   = "50G"
#     volume = "ssd"
#   }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
    vlan_id = "510"
  }

  initialization {
    hostname = var.hostname
    ip_config {
      ipv4 {
        address = "172.16.10.1/25" // We'll set a static IP later if needed
        gateway = "172.16.10.126"
      }
    }
    user_account {
      password = var.password
      keys     = [local.final_ssh_public_key]
    }
  }
    features {
    nesting = var.nesting
  }

}


// Output the generated credentials so you can log in to the container.
output "minio_container_ip_address" {
  description = "The IP address of the MinIO container (will be known after apply)."
  value       = proxmox_virtual_environment_container.minio_server.initialization[0].ip_config[0].ipv4[0].address
}

output "minio_container_root_password" {
  description = "The generated password for the root user."
  value       = random_password.container_password.result
  sensitive   = true
}
