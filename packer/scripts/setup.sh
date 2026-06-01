#!/usr/bin/env bash
# Post-install provisioning for Debian Proxmox template.
# Runs inside the VM via Packer's SSH provisioner after the base OS install.
set -euo pipefail

echo "=== Provisioning Debian Proxmox template ==="

# 1. Configure cloud-init for Proxmox
# Proxmox uses the NoCloud / ConfigDrive datasource
mkdir -p /etc/cloud/cloud.cfg.d
cat > /etc/cloud/cloud.cfg.d/99_proxmox.cfg << 'CLOUD'
datasource_list: [ ConfigDrive, NoCloud, None ]
datasource:
  ConfigDrive:
    dsmode: local
  NoCloud:
    dsmode: local

# Ensure user 'andy' is configured for cloud-init SSH key injection
system_info:
  default_user:
    name: andy
    lock_passwd: false
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
CLOUD

# 2. Ensure qemu-guest-agent is running (enables Proxmox to see VM IP, etc.)
systemctl enable --now qemu-guest-agent

# 3. Clean up machine-id so each clone gets a unique one
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

# 4. Remove temporary SSH host keys (regenerated on first boot per clone)
rm -f /etc/ssh/ssh_host_*

# 5. Enable SSH passwordless sudo for user andy (already in the cloud-init config
#    above, but also set directly as a fallback)
echo "andy ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/andy-cloud-init

# 6. Clean apt cache to shrink image size
apt-get clean
apt-get autoremove --purge -y
rm -rf /var/lib/apt/lists/*

# 7. Truncate logs
find /var/log -type f -name '*.log' -exec truncate -s 0 {} \;
truncate -s 0 /var/log/syslog 2>/dev/null || true
truncate -s 0 /var/log/messages 2>/dev/null || true

# 8. Remove temporary preseed / install artifacts
rm -f /root/.bash_history /home/andy/.bash_history
rm -rf /var/log/installer

# 9. Zero free space for optimal ZFS compression
dd if=/dev/zero of=/zero bs=1M || true
rm -f /zero

echo "=== Provisioning complete ==="
