# Virtual Machine Module

This module creates Azure Virtual Machines with managed disks.

## Resources Created

- Azure Virtual Machine
- Network Interface
- Managed OS Disk
- Optional data disks

## Usage

```hcl
module "virtual_machine" {
  source = "../../modules/virtual-machine"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.subnet_ids["vms"]
  
  vm_size            = "Standard_D2s_v3"
  admin_username     = "azureadmin"
  admin_ssh_key_path = "~/.ssh/id_rsa.pub"
  
  tags = var.tags
}
```

## Naming Convention

- VM: `vm-{customer}-{env}-{region}-{instance}`
- NIC: `nic-{customer}-{env}-{region}-{instance}`

## Features

- Linux or Windows VMs
- SSH or password authentication
- Managed disks (Standard/Premium SSD)
- Auto-shutdown schedules (optional)
