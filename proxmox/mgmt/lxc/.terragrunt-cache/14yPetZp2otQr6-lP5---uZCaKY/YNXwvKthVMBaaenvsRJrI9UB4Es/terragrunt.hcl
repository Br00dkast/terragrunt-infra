// File: production/services/lxc/terragrunt.hcl
//
// This file defines all LXC containers that are considered "services".

// This block inherits all the logic (backend, providers, shared variables)
// from your root.hcl file.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

// Point to the reusable LXC module.
terraform {
  source = "../../../../opentofu/modules/lxc"
}

// Define the inputs for the module.
inputs = {
  // --- Shared Network Settings for this Group ---
  shared_vlan_id        = 99
  shared_gateway        = "192.168.99.254"
  shared_netbox_vlan_id = 3

  shared_password       = get_env("SHARED_PASSWORD", "")
  shared_ssh_public_key = get_env("SHARED_SSH_PUBLIC_KEY", "")
  
  // Define all the LXC containers for this service group in this map.
  lxc_containers = {
    "lxc-mgmt-netbird" = {
      hostname            = "lxc-mgmt-netbird"
      pool_id             = "backup-normal"
      node_name           = "pve-node02"
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 10
      unprivileged        = true
      nesting             = true
      tags                = [ "lxc" , "netbird" , "mgmt" ]
      manage_credentials  = false
      
      network_interfaces = [
        {
          name        = "eth0"
          bridge      = "vmbr0"
          enable_ipam = true
        }
      ]

      enable_netbox_device  = true
      netbox_device_type_id = 1
      netbox_role_id        = 4
      netbox_site_id        = 1
      netbox_cluster_id     = 1
    },
    "lxc-mgmt-semaphore" = {
      hostname            = "lxc-mgmt-semaphore"
      pool_id             = "backup-normal"
      node_name           = "pve-node02"
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 2
      memory_dedicated    = 2048
      disk_datastore_id   = "ceph"
      disk_size           = 30
      unprivileged        = true
      nesting             = true
      tags                = [ "lxc" , "semaphore" , "mgmt" ]
      
      network_interfaces = [
        {
          name        = "eth0"
          bridge      = "vmbr0"
          enable_ipam = true
        }
      ]

      enable_netbox_device  = true
      netbox_device_type_id = 1
      netbox_role_id        = 4
      netbox_site_id        = 1
      netbox_cluster_id     = 1
      dns_config  = {
        cname_alias         = "semaphore"
      }
    },
  }
}
