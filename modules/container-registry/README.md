# Azure Container Registry Module

This module creates an Azure Container Registry (ACR) for storing Docker images and OCI artifacts.

## Resources Created

- Azure Container Registry
- Private endpoint (optional)
- Geo-replication (Premium tier)

## Usage

```hcl
module "container_registry" {
  source = "../../modules/container-registry"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  sku                  = "Premium"  # Basic, Standard, Premium
  admin_enabled        = false      # Use service principal or managed identity
  public_network_access = false
  
  tags = var.tags
}
```

## Naming Convention

- Container Registry: `acr{customer}{env}{region}{instance}`
  - Example: `acrcontosoprodeus001` (no hyphens, lowercase, alphanumeric only)
  - Must be globally unique

## SKU Tiers

| Tier | Storage | Webhooks | Geo-replication | Use Case |
|------|---------|----------|-----------------|----------|
| Basic | 10 GB | 2 | No | Dev/test |
| Standard | 100 GB | 10 | No | Small production |
| Premium | 500 GB | 500 | Yes | Enterprise production |

## Features

- Private Docker registry
- Geo-replication (Premium)
- Image vulnerability scanning
- Content trust
- Private endpoints
- Azure AD authentication
- Webhooks for CI/CD
