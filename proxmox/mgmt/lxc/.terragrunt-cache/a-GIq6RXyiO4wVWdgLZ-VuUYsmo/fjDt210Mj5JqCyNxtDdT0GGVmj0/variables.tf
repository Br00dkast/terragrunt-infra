// -----------------------------------------------------------------------------
//
//                                variables.tf
//
// This file defines the input variables. The key change is the addition
// of the 'mount_points' attribute, which is a list of objects.
//
// -----------------------------------------------------------------------------

variable "lxc_containers" {
  type = map(object({
    // --- Required attributes for each container ---
    hostname            = string
    os_template_file_id = string
    
    // --- Optional attributes with defaults for each container ---
    vm_id            = optional(number)
    node_name        = optional(string, "pve-node01")
    pool_id          = optional(string)
    description      = optional(string, "Managed by OpenTofu")
    disk_size        = optional(number, 8)
    disk_datastore_id= optional(string, "ceph")
    cores            = optional(number, 1)
    memory_dedicated = optional(number, 512)
    swap             = optional(number, 512)
    unprivileged     = optional(bool, true)
    nesting          = optional(bool, true)
    os_type          = optional(string, "debian")
    tags             = optional(list(string), [])
    manage_credentials  = optional(bool, true)
    
    // --- Network Interfaces: A list of objects ---
    network_interfaces = optional(list(object({
      name             = string // e.g., "eth0", "eth1"
      bridge           = string
      vlan_id          = optional(number, -1)
      
      // IPAM configuration for this specific interface
      enable_ipam      = optional(bool, false)
      netbox_vlan_id   = optional(number)
      static_ip        = optional(string) // e.g., "192.168.10.10/24"
      gateway          = optional(string) // The gateway is now defined per-interface
    })), [])

    mount_points = optional(list(object({
      path    = string
      size    = string
      volume  = string
    })), [])

    enable_netbox_device = optional(bool, false)
    netbox_device_type_id  = optional(number)
    netbox_role_id         = optional(number)
    netbox_site_id         = optional(number)
    netbox_cluster_id      = optional(number)
  }))
  description = "A map of LXC containers to create. Each object can have its own specific configuration, including multiple network interfaces with static or dynamic IPs."
}

// --- User Account & SSH ---
variable "shared_password" {
  type        = string
  description = "A single password to be used for all containers in this group. If left empty, a new random password will be generated for the group."
  default     = ""
  sensitive   = true
}

variable "shared_ssh_public_key" {
  type        = string
  description = "A single public SSH key to be used for all containers in this group. If left empty, a new key pair will be generated for the group."
  default     = ""
}

// --- Shared Network Settings for the Entire Group ---
variable "shared_vlan_id" {
  type        = number
  description = "A single VLAN ID to be used for all interfaces in this group."
  default     = -1
}

variable "shared_gateway" {
  type        = string
  description = "A single gateway to be used for all IPAM-enabled interfaces in this group."
  default     = null
}

variable "shared_netbox_vlan_id" {
  type        = number
  description = "A single NetBox VLAN ID to be used for all IPAM-enabled interfaces in this group."
  default     = null
}