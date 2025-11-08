// File: production/lab/vm/terragrunt.hcl

// Inherit the backend and provider configurations from the root.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

// THIS IS THE FIX: Load the necessary environment variables directly in this file.
// This ensures they are available for the 'inputs' block below.
locals {
  root = read_terragrunt_config(find_in_parent_folders("root.hcl")).locals
  shared_username       = get_env("SHARED_USERNAME", "")
  shared_password       = get_env("SHARED_PASSWORD", "")
  shared_ssh_public_key = get_env("SHARED_SSH_PUBLIC_KEY", "")
  common_user_data = <<-EOT
      #cloud-config
      # Define the user account
      users:
        - name: ansible
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${local.shared_ssh_public_key}
      
      # Set the password for the new user
      chpasswd:
        list: |
          ansible:${local.shared_password}
        expire: False

      # Install necessary packages
      package_update: true
      packages:
        - qemu-guest-agent
      runcmd:
        - [ systemctl, enable, --now, qemu-guest-agent ]
    EOT
}


// Point to the reusable VM module.
terraform {
  source = "${local.root.module_repo_url}//vm?ref=main"
}

// Define the inputs for this group of lab VMs.
inputs = {
  // Shared credentials for the root user, now sourced from the local block above.
  shared_password       = local.shared_password
  shared_ssh_public_key = local.shared_ssh_public_key

  // Shared network settings for this group
  shared_vlan_id        = 101
  shared_gateway        = "192.168.101.254"
  shared_netbox_vlan_id = 18

  // Define the VMs to be created
  vms = {
    "vm-lab-clab01" = {
      hostname         = "vm-lab-clab01"
      template_file_id = "cephfs:import/debian-12-generic-amd64.qcow2"
      pool_id          = "backup-normal"
      tags             = ["lab", "clab"]
      node_name        = "pve-node03"
      cpu_type         = "host" // For nested virtualization
      cores            = 8
      memory           = 16384
      vm_id            = 301
      root_disk_size   = 40
      
      network_interfaces = [
        {
          bridge      = "vmbr0"
          enable_ipam = true // Get the next available IP from NetBox
        }
      ]
      user_data = local.common_user_data

        
      // NetBox integration settings
      enable_netbox_device  = true
      netbox_device_type_id = 1
      netbox_role_id        = 5
      netbox_site_id        = 1
      netbox_cluster_id     = 1
    }
  }
}
