# Packer template: Debian 13 (Trixie) Proxmox VM Template
# Build parameters — override via -var or packer-variables.hcl
# Usage: packer build .
# Build: packer build -var debian_version=13.5.0 .

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint URL (without /api2/json)"
  default     = env("PROXMOX_ENDPOINT")
}

variable "proxmox_token_name" {
  type        = string
  description = "Proxmox API token name (format: USER@REALM!TOKENID)"
  default     = env("PROXMOX_TOKEN_NAME")
}

variable "proxmox_token_secret" {
  type        = string
  sensitive   = true
  description = "Proxmox API token secret"
  default     = env("PROXMOX_TOKEN_VALUE")
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
  default     = "pve1"
}

variable "vm_id" {
  type        = number
  description = "VM ID for the template (auto if empty)"
  default     = null
}

variable "template_name" {
  type        = string
  description = "Name of the resulting Proxmox template"
  default     = "Debian13Template"
}

variable "debian_version" {
  type        = string
  description = "Debian point release version (for display / preseed)"
  default     = "13.5.0"
}

variable "iso_file" {
  type        = string
  description = "Path to Debian netinstall ISO on Proxmox storage"
  default     = "local:iso/debian-13.4.0-amd64-netinst.iso"
}

variable "disk_pool" {
  type        = string
  description = "Proxmox storage pool for the template disk"
  default     = "zfs1"
}

variable "disk_size" {
  type        = string
  description = "Template disk size (e.g. 10G, 16G)"
  default     = "10G"
}

variable "vm_memory" {
  type        = number
  description = "RAM in MB"
  default     = 1024
}

variable "vm_cores" {
  type        = number
  description = "CPU cores"
  default     = 1
}

variable "ssh_username" {
  type        = string
  description = "SSH user for Packer to connect after install"
  default     = "andy"
}

variable "ssh_password" {
  type        = string
  sensitive   = true
  description = "SSH password for Packer (matches preseed.cfg)"
  default     = "debian"
}

variable "bridge" {
  type        = string
  description = "Proxmox bridge for network"
  default     = "vmbr0"
}

# ---------------------------------------------------------------------------
# Builder: Proxmox ISO
# ---------------------------------------------------------------------------

source "proxmox-iso" "debian" {
  proxmox_url              = var.proxmox_endpoint
  username                 = var.proxmox_token_name
  token                    = var.proxmox_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM identity
  vm_id   = var.vm_id
  vm_name = var.template_name
  tags    = "debian;template;packer"

  # OS & boot
  boot_iso {
    iso_file = var.iso_file
  }
  http_directory = "http"
  boot_wait = "15s"
  boot_command = [
    "<wait>c<wait>",
    "linux /install.amd/vmlinuz auto-install/enable=true url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>",
    "initrd /install.amd/initrd.gz<enter>",
    "boot<enter>"
  ]

  # Hardware
  cores        = var.vm_cores
  memory       = var.vm_memory
  os           = "l26"
  bios         = "ovmf"

  disks {
    type         = "scsi"
    disk_size    = var.disk_size
    storage_pool = var.disk_pool
    format       = "raw"
  }

  network_adapters {
    bridge   = var.bridge
    model    = "virtio"
    firewall = false
  }

  # Agent
  qemu_agent = true

  # SSH connection
  ssh_username       = var.ssh_username
  ssh_password       = var.ssh_password
  ssh_timeout        = "20m"
  ssh_handshake_attempts = 100

  # Convert to template when done
  template_name = var.template_name
}

# ---------------------------------------------------------------------------
# Build block
# ---------------------------------------------------------------------------

build {
  name    = "debian-${var.debian_version}"
  sources = ["source.proxmox-iso.debian"]

  # Run provisioning script
  provisioner "shell" {
    scripts = ["scripts/setup.sh"]
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
  }

  # Final cleanup / verify
  provisioner "shell" {
    inline = [
      "echo '=== Template build complete ==='",
      "cloud-init --version",
      "qemu-ga --version | head -1",
      "df -h / | tail -1"
    ]
  }
}
