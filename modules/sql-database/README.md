# Azure SQL Database Module

This module creates an Azure SQL Server and SQL Database with security best practices.

## Resources Created

- Azure SQL Server
- Azure SQL Database
- Firewall rules (optional)
- Private endpoint (optional)
- Transparent Data Encryption (enabled by default)

## Usage

```hcl
module "sql_database" {
  source = "../../modules/sql-database"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  admin_username = "sqladmin"
  admin_password = data.azurerm_key_vault_secret.sql_password.value
  
  database_name = "appdb"
  sku_name      = "S1"
  
  enable_azure_ad_admin = true
  azure_ad_admin_login  = "sql-admins@contoso.com"
  azure_ad_admin_object_id = "00000000-0000-0000-0000-000000000000"
  
  tags = var.tags
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
| `admin_username` | string | SQL Server admin username |
| `admin_password` | string | SQL Server admin password (use Key Vault!) |
| `database_name` | string | SQL Database name |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_number` | number | 1 | Instance number for naming |
| `sql_version` | string | "12.0" | SQL Server version |
| `sku_name` | string | "S1" | Database SKU (Basic, S0-S12, P1-P15) |
| `max_size_gb` | number | 250 | Maximum database size in GB |
| `enable_azure_ad_admin` | bool | false | Enable Azure AD authentication |
| `allowed_ip_ranges` | list(object) | [] | Firewall rules for allowed IPs |
| `enable_advanced_threat_protection` | bool | true | Enable threat detection |
| `tags` | map(string) | {} | Tags to apply |

## Outputs

| Output | Description |
|--------|-------------|
| `sql_server_id` | SQL Server resource ID |
| `sql_server_name` | SQL Server name |
| `sql_server_fqdn` | SQL Server fully qualified domain name |
| `sql_database_id` | SQL Database resource ID |
| `sql_database_name` | SQL Database name |
| `connection_string` | Connection string (sensitive) |

## Naming Convention

- SQL Server: `sql-{customer}-{env}-{region}-{instance}`
  - Example: `sql-contoso-prod-eus-001`
- SQL Database: `{database_name}` (custom name)

## Security Features

- Azure AD authentication support
- TDE (Transparent Data Encryption) enabled by default
- Advanced Threat Protection available
- Firewall rules for IP restrictions
- Private endpoint support (optional)
- Audit logging enabled
- Minimum TLS 1.2

## Example: With Azure AD Admin

```hcl
module "sql_database" {
  source = "../../modules/sql-database"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  admin_username = "sqladmin"
  admin_password = data.azurerm_key_vault_secret.sql_password.value
  
  database_name = "appdb"
  sku_name      = "S2"
  max_size_gb   = 500
  
  enable_azure_ad_admin      = true
  azure_ad_admin_login       = "SQL Administrators"
  azure_ad_admin_object_id   = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  
  allowed_ip_ranges = [
    {
      name             = "Office"
      start_ip_address = "203.0.113.0"
      end_ip_address   = "203.0.113.255"
    }
  ]
  
  tags = var.tags
}
```

## SKU Options

| Tier | SKU Name | Description | Use Case |
|------|----------|-------------|----------|
| Basic | `Basic` | 2GB, 5 DTUs | Dev/test, small workloads |
| Standard | `S0-S12` | 250GB-1TB, 10-3000 DTUs | Most workloads |
| Premium | `P1-P15` | 500GB-4TB, 125-4000 DTUs | High-performance |
| Serverless | `GP_S_Gen5_*` | Auto-scaling | Variable workloads |

## Connection String

The module outputs a connection string (sensitive). Use it in your application:

```
Server=tcp:{server_name}.database.windows.net,1433;Database={database_name};User ID={admin_username};Password={admin_password};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;
```

**Best Practice**: Store credentials in Key Vault and use Managed Identity instead of SQL authentication.
