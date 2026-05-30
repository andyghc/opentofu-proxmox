# OpenTofu Proxmox

Infrastructure-as-Code for my Proxmox homelab — VM provisioning with OpenTofu, config management with Ansible (coming soon).

## Structure

```
opentofu-proxmox/
├── environments/          # Environment-specific configurations
│   └── homelab/           # My home lab environment
│       ├── main.tf        # Resources and modules for this env
│       ├── variables.tf   # Input variables for this env
│       └── .terraform/
├── modules/               # Reusable OpenTofu modules
│   └── proxmox-vm/        # Proxmox VM module (bpg/proxmox provider)
├── .github/workflows/     # GitHub Actions CI/CD
│   ├── plan.yaml          # Plan on PR
│   └── apply.yaml         # Apply on merge to main
└── README.md
```

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.9
- Proxmox VE 8+ with an API token
- A cloud-init ready VM template (e.g. Debian 12)

## Getting Started

```bash
# Clone the repo
git clone https://github.com/andyghc/opentofu-proxmox.git
cd opentofu-proxmox/environments/homelab

# Set up your vars (or use environment variables)
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Proxmox details

# Initialize and plan
tofu init
tofu plan

# Apply
tofu apply
```

## Workflow

1. Create a feature branch and make changes
2. Open a pull request → GitHub Actions runs `tofu plan`
3. Merge to main → GitHub Actions runs `tofu apply`

## Proxmox API Token Setup

On your Proxmox host:

```bash
# Create a role with minimal permissions
pveum role add opentofu -privs "VM.Allocate VM.Clone VM.Config.Disk VM.Config.CPU VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.PowerMgmt Datastore.AllocateSpace Datastore.AllocateTemplate"

# Create a user for automation
pveum user add opentofu@pve

# Create an API token
pveum user token add opentofu@pve opentofu --privsep 0

# Assign the role
pveum aclmod / -user opentofu@pve -role opentofu
```

## Environment Variables for CI

In your GitHub repo, set these secrets:
- `PROXMOX_ENDPOINT` — Proxmox API URL
- `PROXMOX_API_TOKEN` — API token string
- `PROXMOX_NODE` — Node name
- `TF_VAR_vm_ssh_keys` — SSH public keys for cloud-init
