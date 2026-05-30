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

resource "proxmox_virtual_environment_vm" "this" {
  node_name    = var.proxmox_node
  name         = var.vm_name
  description  = var.vm_description
  tags         = var.vm_tags
  template     = var.vm_template_id != null ? null : var.vm_template_name
  clone {
    id        = var.vm_template_id
    node_name = var.proxmox_node
    full      = var.full_clone
    retries   = 3
  }
  started      = var.vm_start
  on_boot      = var.vm_start
  stop_on_destroy = var.stop_on_destroy

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
