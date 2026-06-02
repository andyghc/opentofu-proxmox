# Proxmox VM Module
# Creates a Proxmox virtual machine from a template with cloud-init

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

# Resolve the template VM ID — either explicit or looked up by name
data "proxmox_virtual_environment_vms" "template" {
  count = var.vm_template_id != null ? 0 : 1
  filter {
    name   = "name"
    values = [var.vm_template_name]
  }
}

locals {
  template_vm_id = var.vm_template_id != null ? var.vm_template_id : data.proxmox_virtual_environment_vms.template[0].vms[0].vm_id
}

resource "proxmox_virtual_environment_vm" "this" {
  node_name    = var.proxmox_node
  name         = var.vm_name
  description  = var.vm_description
  tags         = var.vm_tags

  clone {
    vm_id     = local.template_vm_id
    node_name = var.proxmox_node
    full      = var.full_clone
    retries   = 3
  }
  started      = var.vm_start
  on_boot      = var.vm_start
  stop_on_destroy = var.stop_on_destroy
  bios         = var.vm_bios

  cpu {
    cores       = var.vm_cores
    sockets     = var.vm_sockets
    type        = var.cpu_type
    numa        = var.numa_enabled
  }

  memory {
    dedicated = var.vm_memory
    floating  = var.vm_memory
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.datastore_id
      file_format  = disk.value.file_format
      interface    = disk.value.interface
      size         = disk.value.size
      discard      = lookup(disk.value, "discard", null)
      ssd          = lookup(disk.value, "ssd", null)
      cache        = lookup(disk.value, "cache", "none")
      iothread     = lookup(disk.value, "iothread", true)
    }
  }

  dynamic "network_device" {
    for_each = var.network_interfaces
    content {
      bridge      = network_device.value.bridge
      model       = lookup(network_device.value, "model", "virtio")
      vlan_id     = lookup(network_device.value, "vlan_id", null)
      mac_address = lookup(network_device.value, "mac_address", null)
      firewall    = lookup(network_device.value, "firewall", false)
    }
  }

  operating_system {
    type = "l26"
  }

  dynamic "initialization" {
    for_each = var.cloud_init_enabled ? [1] : []
    content {
      ip_config {
        ipv4 {
          address = var.vm_ip_address
          gateway = var.vm_gateway
        }
      }

      dns {
        servers = var.dns_servers
        domain  = var.dns_domain
      }

      user_account {
        username = var.vm_username
        password = var.vm_password
        keys     = var.vm_ssh_keys
      }

      upgrade = var.upgrade_packages
    }
  }

  dynamic "efi_disk" {
    for_each = var.vm_bios == "ovmf" ? [1] : []
    content {
      datastore_id      = var.efi_disk_datastore_id
      file_format       = var.efi_disk_file_format
      type              = var.efi_disk_type
      pre_enrolled_keys = var.efi_disk_pre_enrolled_keys
    }
  }

  agent {
    enabled = var.qemu_agent_enabled
    trim    = var.qemu_agent_enabled
  }

  lifecycle {
    ignore_changes = [
      disk[0].file_format,
      disk[0].interface,
      clone,
    ]
  }
}
