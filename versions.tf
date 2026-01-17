terraform {
  required_version = ">= 1.2.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.87.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.5.0"
    }
    netbox = {
      source  = "rypti-org/netbox"
      version = "5.0.0"
    }
    powerdns = {
      source = "pan-net/powerdns"
      version = "1.5.0"
    }
  }
  backend "s3" {
    bucket     = "terraform"
    key        = "terraform/network/terraform.tfstate"
    region     = "us-east-2"
    encrypt    = false
    use_path_style = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_metadata_api_check = true
    skip_region_validation = true
    endpoints = {
      s3 = "https://s3.network.lan"
    }  
  }
}
