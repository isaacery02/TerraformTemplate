# Storage Account Module

This module creates an Azure Storage Account with security best practices enabled.

## Resources Created

- Azure Storage Account
- Private Endpoint (optional)
- Blob containers (optional)

## Usage

```hcl
module "storage_account" {
  source = "../../modules/storage-account"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_only        = true
  min_tls_version          = "TLS1_2"
  
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
| `location` | string | Azure region |
| `location_code` | string | Short region code |
| `resource_group_name` | string | Resource group name |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_number` | number | 1 | Instance number for naming |
| `account_tier` | string | "Standard" | Storage account tier |
| `account_replication_type` | string | "LRS" | Replication type (LRS, GRS, ZRS) |
| `enable_https_only` | bool | true | Require HTTPS only |
| `min_tls_version` | string | "TLS1_2" | Minimum TLS version |
| `blob_containers` | list(string) | [] | List of container names to create |
| `tags` | map(string) | {} | Tags to apply |

## Outputs

| Output | Description |
|--------|-------------|
| `storage_account_id` | Storage Account resource ID |
| `storage_account_name` | Storage Account name |
| `primary_blob_endpoint` | Primary blob endpoint URL |
| `primary_access_key` | Primary access key (sensitive) |

## Naming Convention

- Storage Account: `st{customer}{env}{region}{instance}` (no hyphens, lowercase)
  - Example: `stcontosoprodeus001`

## Security Features

- HTTPS-only traffic enforced
- Minimum TLS 1.2
- No public blob access by default
- Infrastructure encryption enabled
- Shared key access can be disabled (optional)

## Example: With Blob Containers

```hcl
module "storage_account" {
  source = "../../modules/storage-account"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  blob_containers = ["data", "backups", "logs"]
  
  tags = var.tags
}
```
