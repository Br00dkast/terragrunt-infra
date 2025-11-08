// -----------------------------------------------------------------------------
//
//                                  main.tf
//
// -----------------------------------------------------------------------------
// --- Resource Generation (Passwords, Keys) ---
// (This section remains unchanged)
resource "random_password" "container_password" {
  for_each = var.lxc_containers
  length   = 24
  special  = true
}
resource "tls_private_key" "container_key" {
  for_each  = var.lxc_containers
  algorithm = "RSA"
  rsa_bits  = 4096
}

// --- NetBox Integration Resources ---

data "netbox_prefixes" "by_vlan" {
  for_each = local.dynamic_ip_interfaces
  filter {
    name  = "vlan_id"
    value = var.shared_netbox_vlan_id
  }
}
resource "netbox_virtual_machine" "this" {
  for_each       = { for k, v in var.lxc_containers : k => v if v.enable_netbox_device }
  name           = each.value.hostname
  status         = "active"
  cluster_id     = each.value.netbox_cluster_id
  role_id        = each.value.netbox_role_id
  site_id        = each.value.netbox_site_id
}

// Create a virtual interface in NetBox for each interface on each device.
resource "netbox_interface" "this" {
  for_each           = { for item in local.all_interfaces : item.flat_key => item if item.enable_netbox_device }
  name               = each.value.interface_name
  virtual_machine_id = netbox_virtual_machine.this[each.value.container_key].id
}

// Assign the IP using the modern 'virtual_machine_interface_id' attribute.
resource "netbox_available_ip_address" "dynamic_ip" {
  for_each     = local.dynamic_ip_interfaces
  prefix_id                    = data.netbox_prefixes.by_vlan[each.key].prefixes[0].id
  status                       = "active"
  description                  = "Provisioned by OpenTofu for ${netbox_virtual_machine.this[each.value.container_key].name}"
  virtual_machine_interface_id = netbox_interface.this[each.key].id
}


// Assign the IP using the modern 'virtual_machine_interface_id' attribute.
resource "netbox_ip_address" "static_ip" {
  for_each     = local.static_ip_interfaces
  ip_address   = each.value.nic_config.static_ip
  status       = "active"
  description  = "Provisioned by OpenTofu"

  virtual_machine_interface_id = netbox_interface.this[each.key].id
}

resource "netbox_primary_ip" "static" {
  for_each = local.static_ip_interfaces

  # The ID of the virtual machine this IP belongs to.
  virtual_machine_id = netbox_virtual_machine.this[each.value.container_key].id

  # The ID of the statically created IP address.
  ip_address_id = netbox_ip_address.static_ip[each.key].id
}

resource "netbox_primary_ip" "dynamic" {
  for_each = local.dynamic_ip_interfaces

  # The ID of the virtual machine this IP belongs to.
  virtual_machine_id = netbox_virtual_machine.this[each.value.container_key].id

  # The ID of the dynamically created IP address.
  ip_address_id = netbox_available_ip_address.dynamic_ip[each.key].id
}
# // --- DNS ---
# 1. A-Records for the container's hostname
resource "adguard_rewrite" "a_primary" {
  provider = adguard.primary
  
  # --- THIS IS THE FIX ---
  # This for_each loop is now static. It only looks at your input variables
  # to decide IF a record should be created.
  for_each = {
    for k, v in var.lxc_containers : k => v
    if v.dns_config != null && v.dns_config.enable_a_record == true && (
      # This logic checks if an IP will be available, using only static data
      v.network_interfaces[0].static_ip != null || 
      (v.network_interfaces[0].enable_ipam == true && v.enable_netbox_device == true)
    )
  }
  # --- END FIX ---

  domain = "${each.value.hostname}.${var.shared_domain_suffix}"
  
  # The 'answer' can be dynamic (resolved at apply time).
  # This logic finds the correct IP, whether it's static or from NetBox.
  answer = split("/", (
    each.value.network_interfaces[0].static_ip != null 
    ? each.value.network_interfaces[0].static_ip 
    : local.final_ip_addresses["${each.key}-eth0"]
  ))[0]
}

resource "adguard_rewrite" "a_secondary" {
  provider = adguard.secondary

  # --- THIS IS THE FIX ---
  for_each = {
    for k, v in var.lxc_containers : k => v
    if v.dns_config != null && v.dns_config.enable_a_record == true && (
      v.network_interfaces[0].static_ip != null || 
      (v.network_interfaces[0].enable_ipam == true && v.enable_netbox_device == true)
    )
  }
  # --- END FIX ---

  domain = "${each.value.hostname}.${var.shared_domain_suffix}"
  answer = split("/", (
    each.value.network_interfaces[0].static_ip != null 
    ? each.value.network_interfaces[0].static_ip 
    : local.final_ip_addresses["${each.key}-eth0"]
  ))[0]
}

# 2. CNAME-Records for the service alias (This was already correct)
resource "adguard_rewrite" "cname_primary" {
  provider = adguard.primary
  for_each = {
    for k, v in var.lxc_containers : k => v
    if v.dns_config != null && v.dns_config.cname_alias != null
  }

  domain = "${each.value.dns_config.cname_alias}.${var.shared_domain_suffix}"
  answer = var.shared_npm_cname_target
}

resource "adguard_rewrite" "cname_secondary" {
  provider = adguard.secondary
  for_each = {
    for k, v in var.lxc_containers : k => v
    if v.dns_config != null && v.dns_config.cname_alias != null
  }

  domain = "${each.value.dns_config.cname_alias}.${var.shared_domain_suffix}"
  answer = var.shared_npm_cname_target
}

// --- Main Proxmox Container Resource ---

resource "proxmox_virtual_environment_container" "this" {
  for_each     = var.lxc_containers
  node_name    = each.value.node_name
  vm_id        = each.value.vm_id 
  pool_id      = each.value.pool_id
  description  = each.value.description
  unprivileged = each.value.unprivileged
  tags         = each.value.tags
  features {
    nesting = each.value.nesting
  }

  operating_system {
    template_file_id = each.value.os_template_file_id
    type             = each.value.os_type
  }

  disk {
    datastore_id = each.value.disk_datastore_id
    size         = each.value.disk_size
  }

  dynamic "mount_point" {
    for_each = each.value.mount_points
    content {
      path   = mount_point.value.path
      size   = mount_point.value.size
      volume = mount_point.value.volume
    }
  }

  cpu {
    cores = each.value.cores
  }

  // UPDATED: Memory block now includes swap
  memory {
    dedicated = each.value.memory_dedicated
    swap      = each.value.swap
  }

  // --- Initialization and Networking ---
  
  initialization {
    hostname = each.value.hostname
    
    // Create one ip_config block for each network interface defined
   dynamic "ip_config" {
      for_each = each.value.network_interfaces
      iterator = nic
      content {
        ipv4 {
          // CORRECTED: This logic now prioritizes a user-defined static IP,
          // then falls back to NetBox, and finally to DHCP.
          address = nic.value.static_ip != null ? nic.value.static_ip : (
            nic.value.enable_ipam && each.value.enable_netbox_device ? local.final_ip_addresses["${each.key}-${nic.value.name}"] : "dhcp"
          )
          // The gateway is only set if a static IP is being used (from any source).
           gateway = (nic.value.enable_ipam && each.value.enable_netbox_device) || nic.value.static_ip != null ? var.shared_gateway : null
        }
      }
    }
    dynamic "user_account" {
      for_each = each.value.manage_credentials ? [1] : []
      content {
        password = var.shared_password
        keys     = [var.shared_ssh_public_key]
      }
    }
  }

  
  // Create one network_interface block for each one defined
  dynamic "network_interface" {
    for_each = each.value.network_interfaces
    iterator = nic
    content {
      name    = nic.value.name
      bridge  = nic.value.bridge
      vlan_id = var.shared_vlan_id == -1 ? null : var.shared_vlan_id
    }
  }
  lifecycle {
  ignore_changes = [
    # This tells OpenTofu to ignore any differences in the template file
    # during the import process.
    pool_id,
    operating_system[0].template_file_id,
    # initialization,
  ]
}


}
