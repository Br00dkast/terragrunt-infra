terraform {
  // This block specifies that we are using a local state.
  // No backend configuration is needed for this initial step.

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.79.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}
provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = true // Set to false if you have a valid, trusted SSL certificate
}