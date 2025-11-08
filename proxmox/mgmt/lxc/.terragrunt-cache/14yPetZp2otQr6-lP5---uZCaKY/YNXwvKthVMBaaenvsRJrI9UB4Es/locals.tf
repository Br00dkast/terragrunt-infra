// --- Local Variables for Complex Data Manipulation ---
locals {
  // Flattened list of all network interfaces across all containers
  all_interfaces = flatten([
    for container_key, container_config in var.lxc_containers : [
      for i, nic in container_config.network_interfaces : {
        container_key        = container_key
        nic_config           = nic
        flat_key             = "${container_key}-eth${i}"
        interface_name       = "eth${i}"
        enable_netbox_device = container_config.enable_netbox_device
      }
    ]
  ])

  // Split the IPAM interfaces into two groups: those that need a dynamic IP and those with a static IP.
  ipam_interfaces = {
    for item in local.all_interfaces : item.flat_key => item
    if item.nic_config.enable_ipam && item.enable_netbox_device
  }
  dynamic_ip_interfaces = { for item in local.ipam_interfaces : item.flat_key => item if item.nic_config.static_ip == null }
  static_ip_interfaces  = { for item in local.ipam_interfaces : item.flat_key => item if item.nic_config.static_ip != null }
  final_ip_addresses = merge(
    { for k, v in netbox_ip_address.static_ip : k => v.ip_address },
    { for k, v in netbox_available_ip_address.dynamic_ip : k => v.ip_address }
  )
}