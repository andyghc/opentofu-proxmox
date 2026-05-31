# Homelab Environment — OpenTofu Configuration
# Manages Proxmox VMs for the home lab

terraform {
  required_version = ">= 1.9"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

# ---------------------------------------------------------------------------
# Provider Configuration
# ---------------------------------------------------------------------------
# These values are passed via environment variables or terraform.tfvars.
# Never commit sensitive values to the repo.
# ---------------------------------------------------------------------------

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure
}

# ---------------------------------------------------------------------------
# Example VM — Application Server
# ---------------------------------------------------------------------------

module "app_server" {
  source = "../../modules/proxmox-vm"

  proxmox_node = var.proxmox_node
  vm_name      = "app-server"
  vm_tags      = ["homelab", "application", "docker"]

  vm_template_name = var.vm_template_name

  vm_cores  = 4
  vm_memory = 8192

  disks = [
    {
      datastore_id = var.vm_datastore
      size         = 16
    }
  ]

  # Static IP example
  cloud_init_enabled = true
  vm_ip_address = "192.168.1.170/24"
  vm_gateway    = "192.168.1.1"
  dns_servers   = ["192.168.1.51", "1.1.1.1"]
  dns_domain    = "homelab.internal"

  vm_username = var.vm_default_username
  vm_ssh_keys = var.vm_ssh_keys

  qemu_agent_enabled = true
}
