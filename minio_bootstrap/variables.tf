// File: variables.tf
//
// This file declares all the variables needed to create the MinIO container.
// You will provide the actual values in a 'terraform.tfvars' file.

variable "proxmox_api_url" {
  type        = string
  description = "The URL for the Proxmox API (e.g., 'https://pve.example.com:8006/')."
}

variable "proxmox_api_token" {
  type        = string
  description = "The full Proxmox API Token, in the format 'USER@REALM!TOKENID=SECRET'."
  sensitive   = true
}

variable "node_name" {
  type        = string
  description = "The name of the Proxmox node to deploy the container to."
  default     = ""
}

variable "hostname" {
  type        = string
  description = "The hostname for the MinIO container."
  default     = ""
}

variable "pool_id" {
  type        = string
  description = "The Proxmox resource pool to assign the container to."
  default     = ""
}

variable "vm_id" {
  type        = string
  description = "The VM ID to assign to the container."
  default     = ""
}

variable "os_template_file_id" {
  type        = string
  description = "The full ID of the OS template to use (e.g., 'local:vztmpl/ubuntu-22.04-standard.tar.gz')."
}

variable "ssh_public_key" {
  type        = string
  description = "An existing public SSH key to add to the container's root user. If left empty, a new key pair will be generated."
  default     = ""
}

variable "password" {
  type        = string
  description = "A custom password for the root user. If left empty, no password will be set."
  default     = null
  sensitive   = true
}

variable "network_bridge" {
  type        = string
  description = "The network bridge for the container's interface."
  default     = "vmbr0"
}

variable "vlan_id" {
  type        = number
  description = "The VLAN ID for the container's network interface. Set to -1 for none."
  default     = -1
}

variable "ip_address" {
  type        = string
  description = "The static IPv4 address in CIDR format (e.g., '192.168.1.10/24'). If left null, DHCP will be used."
  default     = null
}

variable "gateway" {
  type        = string
  description = "The IPv4 gateway. This must be provided if a static IP address is set."
  default     = null
}

variable "unprivileged" {
  type        = bool
  description = "Whether the container should run as an unprivileged user on the host."
  default     = true
}

variable "nesting" {
  type        = bool
  description = "Whether to enable nesting, required for running Docker inside the container."
  default     = true
}