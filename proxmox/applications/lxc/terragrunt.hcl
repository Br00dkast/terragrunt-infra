// File: production/applications/lxc/terragrunt.hcl
//
// This file defines all LXC containers that are considered "applications".

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
  shared_vlan_id        = 520
  shared_gateway        = "172.16.10.254"
  shared_netbox_vlan_id = 13

  shared_password       = get_env("SHARED_PASSWORD", "")
  shared_ssh_public_key = get_env("SHARED_SSH_PUBLIC_KEY", "")

  // Define all the LXC containers for this service group in this map.
  lxc_containers = {
    "lxc-app-n8n" = {
      hostname            = "lxc-app-n8n"
      pool_id             = "backup-normal"
      node_name           = "pve-node01"
      vm_id               = "509"
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 15
      unprivileged        = true
      nesting             = true
      tags                = ["lxc", "app"]
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

      dns_config = {
        cname_alias = "n8n"
      }
    },
    "lxc-app-rss" = {
      hostname            = "lxc-app-rss"
      pool_id             = "backup-normal"
      node_name           = "pve-node01"
      vm_id               = 504
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 512
      disk_datastore_id   = "ceph"
      disk_size           = 20
      nesting             = true
      tags                = ["lxc", "app"]
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

      dns_config = {
        cname_alias = "rss"
      }

    },
    "lxc-app-actualbudget" = {
      hostname            = "lxc-app-actualbudget"
      pool_id             = "backup-critical"
      node_name           = "pve-node01"
      vm_id               = 505
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 50
      nesting             = true
      tags                = ["lxc", "app"]
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

      dns_config = {
        cname_alias = "budget"
      }

    },
    "lxc-app-speedtest" = {
      hostname            = "lxc-app-speedtest"
      pool_id             = "backup-normal"
      node_name           = "pve-node01"
      vm_id               = 506
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 15
      nesting             = true
      tags                = ["lxc", "app"]
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

      dns_config = {
        cname_alias = "speedtest"
      }

    },
    "lxc-app-ittools" = {
      hostname            = "lxc-app-ittools"
      pool_id             = "backup-normal"
      node_name           = "pve-node01"
      vm_id               = 507
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 15
      nesting             = true
      tags                = ["lxc", "app"]
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

      dns_config = {
        cname_alias = "it-tools"
      }

    },
    "lxc-app-linkding" = {
      hostname            = "lxc-app-linkding"
      pool_id             = "backup-normal"
      node_name           = "pve-node02"
      vm_id               = 508
      os_template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
      cores               = 1
      memory_dedicated    = 1024
      disk_datastore_id   = "ceph"
      disk_size           = 15
      nesting             = true
      tags                = ["lxc", "app"]
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

      dns_config = {
        cname_alias = "linkding"
      }

    },
  }
}



# "lxc_actualbudget" = {
#   hostname        = "lxc-actualbudget"
#   cores           = 1
#   memory          = 1024
#   swap            = 512
#   vmid            = 505
#   target_node     = "pve-node01"
#   ip              = "192.168.100.13/24"
#   gw              = "192.168.100.254"
#   vlan_tag        = 100
#   storage_backend = "ceph"
#   disk_size       = "50G"
#   ostemplate      = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
#   backup_pool     = "backup-critical"
#   nesting         = true
#   # keyctl omitted as it's not needed for this container
# },


# "lxc_n8n" = {
#     hostname        = "lxc-n8n"
#     cores           = 1
#     memory          = 1024
#     swap            = 512
#     vmid            = 509
#     target_node     = "pve-node01"
#     ip              = "192.168.100.17/24"
#     gw              = "192.168.100.254"
#     vlan_tag        = 100
#     storage_backend = "ceph"
#     disk_size       = "15G"
#     ostemplate      = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
#     backup_pool     = "backup-normal"
#     nesting         = true
#     # keyctl omitted as it's not needed for this container
#  },
