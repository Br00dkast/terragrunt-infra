# This import block targets a specific instance within the for_each loop
# defined in your main resource block.
import {
   to = proxmox_virtual_environment_container.this["lxc-srv-minio"]
  id = "pve-node03/201"
}
# import {
#    to = proxmox_virtual_environment_container.this["lxc-srv-runner"]
#   id = "pve-node02/202"
# }
# import {
#    to = proxmox_virtual_environment_container.this["lxc-srv-dns01"]
#   id = "pve-node01/203"
# }
# import {
#    to = proxmox_virtual_environment_container.this["lxc-srv-dns02"]
#   id = "pve-node02/204"
# }