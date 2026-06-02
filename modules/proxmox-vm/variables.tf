variable "proxmox_node" {
  description = "Proxmox node to create the VM on"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_description" {
  description = "Description of the virtual machine"
  type        = string
  default     = ""
}

variable "vm_tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = []
}

variable "vm_template_id" {
  description = "Template ID to clone from (alternative to vm_template_name)"
  type        = number
  default     = null
}

variable "vm_template_name" {
  description = "Template name to clone from (used when vm_template_id is null)"
  type        = string
  default     = null
}

variable "full_clone" {
  description = "Create a full clone (not linked)"
  type        = bool
  default     = true
}

variable "vm_start" {
  description = "Start the VM after creation"
  type        = bool
  default     = true
}

variable "stop_on_destroy" {
  description = "Stop the VM when the resource is destroyed"
  type        = bool
  default     = true
}

variable "vm_bios" {
  description = "BIOS implementation (seabios or ovmf)"
  type        = string
  default     = "ovmf"
}

variable "efi_disk_datastore_id" {
  description = "Datastore ID for the EFI disk (only used when bios=ovmf)"
  type        = string
  default     = "zfs1"
}

variable "efi_disk_file_format" {
  description = "File format for the EFI disk (raw or qcow2)"
  type        = string
  default     = "raw"
}

variable "efi_disk_type" {
  description = "EFI disk type (2m or 4m)"
  type        = string
  default     = "4m"
}

variable "efi_disk_pre_enrolled_keys" {
  description = "Pre-enroll Microsoft and Open Source Secure Boot keys"
  type        = bool
  default     = true
}

variable "vm_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "CPU type (host, kvm64, x86-64-v2-AES, etc.)"
  type        = string
  default     = "host"
}

variable "numa_enabled" {
  description = "Enable NUMA"
  type        = bool
  default     = false
}

variable "vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disks" {
  description = "Disk configuration list"
  type = list(object({
    datastore_id = string
    file_format  = optional(string, "raw")
    interface    = optional(string, "scsi0")
    size         = number
    discard      = optional(string, "on")
    ssd          = optional(bool, true)
    cache        = optional(string, "none")
    iothread     = optional(bool, true)
  }))
  default = [
    {
      datastore_id = "local-lvm"
      size         = 32
    }
  ]
}

variable "network_interfaces" {
  description = "Network interface configuration"
  type = list(object({
    bridge      = string
    model       = optional(string, "virtio")
    vlan_id     = optional(number, null)
    mac_address = optional(string, null)
    firewall    = optional(bool, false)
  }))
  default = [
    {
      bridge = "vmbr0"
    }
  ]
}

variable "cloud_init_enabled" {
  description = "Enable cloud-init initialization"
  type        = bool
  default     = true
}

variable "vm_ip_address" {
  description = "Static IP address with CIDR (e.g. 192.168.1.100/24)"
  type        = string
  default     = null
}

variable "vm_gateway" {
  description = "Default gateway"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = null
}

variable "dns_domain" {
  description = "DNS search domain"
  type        = string
  default     = null
}

variable "vm_username" {
  description = "Cloud-init user account username"
  type        = string
  default     = "ansible"
}

variable "vm_password" {
  description = "Cloud-init user account password"
  type        = string
  default     = null
  sensitive   = true
}

variable "vm_ssh_keys" {
  description = "SSH public keys for the cloud-init user"
  type        = list(string)
  default     = []
}

variable "upgrade_packages" {
  description = "Run package upgrade on first boot"
  type        = bool
  default     = true
}

variable "qemu_agent_enabled" {
  description = "Enable the QEMU guest agent"
  type        = bool
  default     = true
}
