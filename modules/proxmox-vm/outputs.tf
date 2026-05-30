output "vm_id" {
  description = "The VM ID assigned by Proxmox"
  value       = proxmox_virtual_environment_vm.this.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = proxmox_virtual_environment_vm.this.name
}

output "vm_ipv4_address" {
  description = "The IPv4 address of the VM (from QEMU agent)"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}

output "network_interface_names" {
  description = "Network interface names from QEMU agent"
  value       = proxmox_virtual_environment_vm.this.network_interface_names
}
