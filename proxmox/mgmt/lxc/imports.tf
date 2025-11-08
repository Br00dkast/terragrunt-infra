# This import block targets a specific instance within the for_each loop
# defined in your main resource block.
import {
  # The resource address now includes the key from your lxc_containers map.
   to = proxmox_virtual_environment_container.this["lxc-mgmt-netbird"]

  # The ID of the existing LXC container in Proxmox.
  id = "pve-node02/111"
}