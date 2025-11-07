# Key Vault Module

This module creates an Azure Key Vault with security best practices enabled.

## Resources Created

- Azure Key Vault
- Access policies (optional)
- RBAC role assignments (optional)

## Usage

```hcl
module "key_vault" {
  source = "../../modules/key-vault"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  enable_rbac_authorization = true
  enabled_for_disk_encryption = true
  
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
| `tenant_id` | string | Azure AD tenant ID |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_number` | number | 1 | Instance number for naming |
| `sku_name` | string | "standard" | Key Vault SKU (standard/premium) |
| `enable_rbac_authorization` | bool | true | Use RBAC instead of access policies |
| `enabled_for_disk_encryption` | bool | true | Enable for Azure Disk Encryption |
| `enabled_for_deployment` | bool | false | Enable for VM deployment |
| `enabled_for_template_deployment` | bool | false | Enable for ARM template deployment |
| `soft_delete_retention_days` | number | 90 | Soft delete retention period |
| `purge_protection_enabled` | bool | true | Enable purge protection |
| `tags` | map(string) | {} | Tags to apply |

## Outputs

| Output | Description |
|--------|-------------|
| `key_vault_id` | Key Vault resource ID |
| `key_vault_name` | Key Vault name |
| `key_vault_uri` | Key Vault URI |

## Naming Convention

- Key Vault: `kv-{customer}-{env}-{region}-{instance}`
  - Example: `kv-contoso-prod-eus-001`
  - Must be 3-24 characters

## Security Features

- RBAC authorization (recommended)
- Soft delete enabled (90-day default)
- Purge protection enabled
- Network ACLs configurable
- Private endpoint support (optional)

## Example: With Access Policies

```hcl
module "key_vault" {
  source = "../../modules/key-vault"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  enable_rbac_authorization = false
  
  access_policies = [
    {
      object_id = data.azurerm_client_config.current.object_id
      secret_permissions = ["Get", "List", "Set", "Delete"]
      key_permissions    = ["Get", "List", "Create", "Delete"]
    }
  ]
  
  tags = var.tags
}
```
