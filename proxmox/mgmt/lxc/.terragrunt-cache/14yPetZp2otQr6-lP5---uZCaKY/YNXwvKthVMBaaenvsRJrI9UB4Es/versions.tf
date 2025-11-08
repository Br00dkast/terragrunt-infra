terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.79.0"
    }
    netbox = {
      source  = "e-breuninger/netbox"
      version = "4.1.0"
    }
    adguard = {
      source  = "gmichels/adguard"
      version = "~> 1.6"
    }
  }
}