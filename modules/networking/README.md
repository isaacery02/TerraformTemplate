# Networking Module

This module creates Azure Virtual Network infrastructure including VNet, Subnets, and Network Security Groups.

## Resources Created

- Azure Virtual Network
- Multiple Subnets (configurable)
- Network Security Groups per subnet
- NSG associations with subnets

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  vnet_address_space = ["10.0.0.0/16"]
  
  subnets = {
    gateway = {
      address_prefix = "10.0.0.0/24"
    }
    appservice = {
      address_prefix = "10.0.1.0/24"
    }
    vms = {
      address_prefix = "10.0.2.0/24"
    }
    data = {
      address_prefix = "10.0.3.0/24"
    }
    mgmt = {
      address_prefix = "10.0.255.0/24"
    }
  }
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `customer_short_name` | string | Short name for customer (3-8 lowercase chars) |
| `environment` | string | Environment (prod, dev, staging) |
| `location` | string | Azure region (e.g., eastus) |
| `location_code` | string | Short region code (e.g., eus) |
| `vnet_address_space` | list(string) | Address space for VNet |
| `subnets` | map(object) | Map of subnets with address_prefix |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_number` | number | 1 | Instance number for naming |
| `tags` | map(string) | {} | Tags to apply to resources |

## Outputs

| Output | Description |
|--------|-------------|
| `vnet_id` | Virtual Network resource ID |
| `vnet_name` | Virtual Network name |
| `subnet_ids` | Map of subnet names to IDs |
| `nsg_ids` | Map of NSG names to IDs |

## Naming Convention

- VNet: `vnet-{customer}-{env}-{region}-{instance}`
- Subnets: `snet-{name}-{customer}-{env}-{region}-{instance}`
- NSGs: `nsg-{subnet}-{customer}-{env}-{region}-{instance}`

## Default Subnet Structure

The module supports common subnet patterns:
- **gateway**: For VPN/ExpressRoute gateways (10.0.0.0/24)
- **appservice**: For App Service integration (10.0.1.0/24)
- **vms**: For virtual machines (10.0.2.0/24)
- **data**: For databases and data services (10.0.3.0/24)
- **mgmt**: For management and bastion (10.0.255.0/24)

## Example: Custom Subnets

```hcl
subnets = {
  frontend = {
    address_prefix = "10.0.10.0/24"
  }
  backend = {
    address_prefix = "10.0.20.0/24"
  }
  database = {
    address_prefix = "10.0.30.0/24"
  }
}
```
