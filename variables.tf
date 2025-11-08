// This file declares all variables for the infrastructure configuration.
// These can be populated by a .tfvars file for local development or by
// environment variables in a CI/CD pipeline.

// --- Proxmox Configuration ---
variable "proxmox_api_url" {
  type        = string
  description = "The URL for the Proxmox API (e.g., 'https://pve.example.com:8006/api2/json')."
  default     = null
}
variable "proxmox_token_id" {
  type        = string
  description = "Proxmox API Token ID."
  default     = null
}
variable "proxmox_secret" {
  type        = string
  description = "Proxmox API Token Secret."
  default     = null
  sensitive   = true
}

// --- NetBox Configuration ---
variable "netbox_server_url" {
  type        = string
  description = "The URL for the NetBox instance."
  default     = null
}
variable "netbox_api_token" {
  type        = string
  description = "NetBox API Token."
  default     = null
  sensitive   = true
}

// --- MinIO S3 Backend Configuration ---
variable "minio_endpoint" {
  type        = string
  description = "The endpoint URL for the MinIO S3 server."
  default     = null
}
variable "minio_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for storing state files."
  default     = null
}
variable "minio_access_key" {
  type        = string
  description = "MinIO Access Key."
  default     = null
}
variable "minio_secret_key" {
  type        = string
  description = "MinIO Secret Key."
  default     = null
  sensitive   = true
}

// --- User Account & SSH ---
variable "shared_password" {
  type        = string
  description = "A single password to be used for all containers in this group. If left empty, a new random password will be generated for the group."
  default     = null
  sensitive   = true
}

variable "shared_ssh_public_key" {
  type        = string
  description = "A single public SSH key to be used for all containers in this group. If left empty, a new key pair will be generated for the group."
  default     = null
}