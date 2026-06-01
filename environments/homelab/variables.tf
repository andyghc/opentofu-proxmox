# ---------------------------------------------------------------------------
# Proxmox Connection
# ---------------------------------------------------------------------------

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL (e.g. https://proxmox.example.com:8006/api2/json)"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token" {
  description = "Proxmox API token ID and secret (format: user@pam!token=uuid)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Target Proxmox node name"
  type        = string
}

# ---------------------------------------------------------------------------
# VM Defaults
# ---------------------------------------------------------------------------

variable "vm_template_name" {
  description = "Default VM template to clone from"
  type        = string
  default     = "Debian13Template"
}

variable "vm_datastore" {
  description = "Default datastore for VM disks"
  type        = string
  default     = "zfs1"
}

variable "vm_default_username" {
  description = "Default cloud-init username"
  type        = string
  default     = "andy"
}

variable "vm_ssh_keys" {
  description = "SSH public keys for cloud-init user"
  type        = list(string)
  default     = []
}
