# Providers configuration
# Vault token is provided via variable `vault_token` (from TF_VAR_vault_token env var)

variable "vault_token" {
  type      = string
  sensitive = true
  default   = null
}

provider "vault" {
  address = "https://vault.network.lan"
  skip_tls_verify = true
}

# Read Terraform secrets from Vault KV (assumes KV v2 mounted at kv/)
data "vault_generic_secret" "terraform_secrets" {
  path = "kv/terraform"
}

data "vault_generic_secret" "powerdns_secrets" {
  path = "kv/powerdns"
}

locals {
  proxmox_api_token_id  = lookup(data.vault_generic_secret.terraform_secrets.data, "proxmox_api_key_id", "")
  proxmox_api_token     = lookup(data.vault_generic_secret.terraform_secrets.data, "proxmox_api_key", "")
  netbox_api_token      = lookup(data.vault_generic_secret.terraform_secrets.data, "netbox_api_key", "")
  ssh_private_key       = lookup(data.vault_generic_secret.terraform_secrets.data, "ssh_privkey", "")
  powerdns_api_token    = lookup(data.vault_generic_secret.powerdns_secrets.data, "api_token", "")
}

provider "proxmox" {
  endpoint   = "https://proxmox.network.lan:8006/"
  api_token = "${local.proxmox_api_token_id}=${local.proxmox_api_token }"
  insecure     = true
  ssh {
    agent = true
    username = "root"
    private_key = local.ssh_private_key
    node {
      name = "pve"
      address = "192.168.0.250"
      port = 22
    }
  }
}

provider "netbox" {
  server_url   = "https://netbox.network.lan"
  api_token = local.netbox_api_token
  allow_insecure_https = true
  request_timeout = 20
}

provider "powerdns" {
  api_key = local.powerdns_api_token
  server_url = "http://dns.network.lan"
  insecure_https = true
}
