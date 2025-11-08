// This file is located at the root of your repository.
// It defines all shared logic and is included by child configurations.
locals {
  proxmox_api_url         = get_env("PROXMOX_API_URL", "")
  proxmox_token_id        = get_env("PROXMOX_TOKEN_ID", "")
  proxmox_secret          = get_env("PROXMOX_SECRET", "")
  proxmox_api_token       = get_env("PROXMOX_API_TOKEN", "")
  proxmox_ssh_private_key = get_env("PROXMOX_SSH_PRIVATE_KEY", "")
  netbox_server_url       = get_env("NETBOX_SERVER_URL", "")
  netbox_api_token        = get_env("NETBOX_API_TOKEN", "")
  minio_endpoint          = get_env("MINIO_ENDPOINT", "")
  minio_bucket_name       = get_env("MINIO_BUCKET_NAME", "")
  minio_access_key        = get_env("MINIO_ACCESS_KEY", "")
  minio_secret_key        = get_env("MINIO_SECRET_KEY", "")
  shared_username         = get_env("SHARED_USERNAME", "")
  shared_password         = get_env("SHARED_PASSWORD", "")
  shared_ssh_public_key   = get_env("SHARED_SSH_PUBLIC_KEY", "")
  adguard_admin_password  = get_env("ADGUARD_ADMIN_PASSWORD", "")
  module_repo_url         = "git::git@github.com:Br00dkast/terragrunt-modules.git"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.is_ci_validation ? "" : <<EOF
terraform {
  backend "s3" {
    bucket                      = "${local.minio_bucket_name}"
    # CORRECTED: This now generates a unique key per component.
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    endpoint                    = "${local.minio_endpoint}"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
    access_key                  = "${local.minio_access_key}"
    secret_key                  = "${local.minio_secret_key}"
    insecure                    = true
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.is_ci_validation ? "" : <<EOF

provider "proxmox" {
  endpoint  = "${local.proxmox_api_url}"
  api_token = "${local.proxmox_api_token}"
  insecure  = true
  ssh {
    agent       = false
    username    = "terragrunt"
    private_key = ${jsonencode(local.proxmox_ssh_private_key)}
  }
}

provider "netbox" {
  server_url = "${local.netbox_server_url}"
  api_token  = "${local.netbox_api_token}"
}

provider "adguard" {
  alias    = "primary"
  host     = "172.16.10.3" # lxc-srv-dns01
  scheme   = "http"
  username = "admin"
  password = "${local.adguard_admin_password}"
  insecure = true
}

provider "adguard" {
  alias    = "secondary"
  host     = "172.16.10.4" # lxc-srv-dns02
  scheme   = "http"
  username = "admin"
  password = "${local.adguard_admin_password}"
  insecure = true
}
EOF
}