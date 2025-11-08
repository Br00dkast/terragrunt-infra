// File: production/services/lxc/terragrunt.hcl
//
// This file defines all LXC containers that are considered "services".

// This block inherits all the logic (backend, providers, shared variables)
// from your root.hcl file.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root = read_terragrunt_config(find_in_parent_folders("root.hcl")).locals
}
// Point to the reusable LXC module.
terraform {
  source = "${local.root.module_repo_url}//lxc?ref=main"
}
// Define the inputs for the module.
inputs = {
  // --- Shared Network Settings for this Group ---
  shared_vlan_id        = 510
  shared_gateway        = "172.16.10.126"
  shared_netbox_vlan_id = 12

  shared_password       = get_env("SHARED_PASSWORD", "")
  shared_ssh_public_key = get_env("SHARED_SSH_PUBLIC_KEY", "")
  
  // Define all the LXC containers for this service group in this map.
  lxc_containers = {
    // --- The MinIO server you imported ---
    "lxc-srv-minio" = {
      hostname            = "lxc-srv-minio"
      pool_id             = "backup-critical"
      node_name           = "pve-node03"
      vm_id               = 201
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 2
      memory_dedicated    = 2048
      disk_datastore_id   = "ceph"
      disk_size           = 30
      unprivileged        = true
      nesting             = true
      tags                = [ "lxc" , "services" ,"s3" ]
      manage_credentials  = false
      
      network_interfaces = [
        {
          name        = "eth0"
          bridge      = "vmbr0"
          # vlan_id     = 510
          enable_ipam = true
          static_ip   = "172.16.10.1/25"
          # gateway     = "172.16.10.126"
        }
      ]

      enable_netbox_device  = true
      netbox_device_type_id = 1
      netbox_role_id        = 4
      netbox_site_id        = 1
      netbox_cluster_id     = 1
    },
    "lxc-srv-runner" = {
      hostname            = "lxc-srv-runner"
      pool_id             = "backup-normal"
      node_name           = "pve-node02"
      vm_id               = 202
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 16
      unprivileged        = true
      nesting             = true
      tags                = [ "lxc" , "services" , "runner" ]
      manage_credentials   = false
      
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
    "lxc-srv-dns01" = {
      hostname            = "lxc-srv-dns01"
      pool_id             = "backup-critical"
      node_name           = "pve-node01"
      vm_id               = 203
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 10
      unprivileged        = true
      nesting             = true
      tags                = [ "lxc" , "services" , "dns" ]
      manage_credentials   = false
      
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
          
      dns_config = {
        cname_alias         = "dns01"
      }
    },
    "lxc-srv-dns02" = {
      hostname              = "lxc-srv-dns02"
      pool_id               = "backup-critical"
      node_name             = "pve-node02"
      vm_id                 = 204
      os_template_file_id   = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores                 = 1
      memory_dedicated      = 1024
      disk_datastore_id     = "ceph"
      disk_size             = 10
      unprivileged          = true
      nesting               = true
      tags                  = [ "lxc" , "services" , "dns" ]
      manage_credentials    = false
      
      network_interfaces = [
        {
          name              = "eth0"
          bridge            = "vmbr0"
          enable_ipam       = true
        }
      ]

      enable_netbox_device  = true
      netbox_device_type_id = 1
      netbox_role_id        = 4
      netbox_site_id        = 1
      netbox_cluster_id     = 1

      dns_config  = {
        cname_alias         = "dns02"
      }
    },
  }
}
