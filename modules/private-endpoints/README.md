# Azure Private Endpoints Module

This module creates Azure Private Endpoints for secure, private connectivity to Azure PaaS services over your Virtual Network.

## Overview

Private Endpoints eliminate the need for public internet exposure of Azure services. Traffic between your VNet and the service travels over the Microsoft backbone network, providing enhanced security and compliance.

## Features

- 🔒 Private connectivity to Azure PaaS services
- 🌐 No public internet exposure required
- 🛡️ Network security group support
- 📍 Private DNS integration
- 🔄 Support for multiple service types
- ⚡ Reduced latency via Microsoft backbone
- 🎯 Granular access control

## Supported Services

This module supports Private Endpoints for:

- **Storage Account** (Blob, File, Queue, Table, DFS)
- **Key Vault** (vault)
- **SQL Database** (sqlServer)
- **Cosmos DB** (SQL, MongoDB, Cassandra, Gremlin, Table)
- **App Service** (sites)
- **Azure Functions** (sites)
- **Container Registry** (registry)
- **Redis Cache** (redisCache)
- **Event Hubs** (namespace)
- **Service Bus** (namespace)
- **PostgreSQL/MySQL** (postgresqlServer, mysqlServer)
- **Azure Search** (searchService)

## Module Structure

```
modules/private-endpoints/
├── main.tf          # Private endpoint and DNS resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
└── README.md        # This file
```

## Simple Usage Example

### Single Private Endpoint (Storage Account)

```hcl
module "private_endpoint_storage" {
  source = "../../modules/private-endpoints"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  # Target resource
  private_connection_resource_id = module.storage_account.storage_account_id
  subresource_names              = ["blob"]  # blob, file, queue, table, dfs

  # Network settings
  subnet_id = module.networking.subnet_ids["data"]

  # DNS integration
  private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]

  # Naming
  endpoint_name = "storage-blob"

  tags = var.tags
}
```

### Multiple Private Endpoints (Common Pattern)

```hcl
# Storage Account - Blob
module "pe_storage_blob" {
  source = "../../modules/private-endpoints"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  private_connection_resource_id = module.storage_account.storage_account_id
  subresource_names              = ["blob"]
  subnet_id                      = module.networking.subnet_ids["data"]
  private_dns_zone_ids          = [azurerm_private_dns_zone.blob.id]
  endpoint_name                  = "storage-blob"

  tags = var.tags
}

# Key Vault
module "pe_keyvault" {
  source = "../../modules/private-endpoints"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  private_connection_resource_id = module.key_vault.key_vault_id
  subresource_names              = ["vault"]
  subnet_id                      = module.networking.subnet_ids["data"]
  private_dns_zone_ids          = [azurerm_private_dns_zone.keyvault.id]
  endpoint_name                  = "keyvault"

  tags = var.tags
}

# SQL Database
module "pe_sql" {
  source = "../../modules/private-endpoints"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  private_connection_resource_id = module.sql_database.sql_server_id
  subresource_names              = ["sqlServer"]
  subnet_id                      = module.networking.subnet_ids["data"]
  private_dns_zone_ids          = [azurerm_private_dns_zone.sql.id]
  endpoint_name                  = "sql"

  tags = var.tags
}
```

## Resource Naming

```
pep-{service}-{customer-short-name}-{environment}-{region-code}-{instance}
```

### Examples
- Storage Blob: `pep-stblob-contoso-prod-eus-001`
- Key Vault: `pep-kv-contoso-prod-eus-001`
- SQL Server: `pep-sql-contoso-prod-eus-001`
- Cosmos DB: `pep-cosmos-contoso-prod-eus-001`

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `customer_short_name` | string | Customer identifier (3-8 chars) |
| `environment` | string | Environment (dev, staging, prod) |
| `location` | string | Azure region |
| `location_code` | string | Short region code |
| `resource_group_name` | string | Resource group name |
| `private_connection_resource_id` | string | Target resource ID |
| `subresource_names` | list(string) | Subresource types (e.g., ["blob"]) |
| `subnet_id` | string | Subnet ID for private endpoint |
| `endpoint_name` | string | Descriptive name for endpoint |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `private_dns_zone_ids` | list(string) | `[]` | Private DNS zone IDs |
| `is_manual_connection` | bool | `false` | Require manual approval |
| `request_message` | string | `null` | Message for manual approval |

## Outputs

| Output | Description |
|--------|-------------|
| `private_endpoint_id` | Private endpoint ID |
| `private_endpoint_name` | Private endpoint name |
| `private_ip_address` | Private IP address assigned |
| `network_interface_id` | NIC ID of the private endpoint |

## Subresource Names Reference

### Storage Account
- `blob` - Blob storage
- `file` - File shares
- `queue` - Queue storage
- `table` - Table storage
- `dfs` - Data Lake Storage Gen2

### Key Vault
- `vault` - Key Vault service

### SQL Database
- `sqlServer` - SQL Server

### Cosmos DB
- `Sql` - SQL API
- `MongoDB` - MongoDB API
- `Cassandra` - Cassandra API
- `Gremlin` - Gremlin (Graph) API
- `Table` - Table API

### App Service / Functions
- `sites` - App Service or Function App

### Container Registry
- `registry` - Container Registry

### Redis Cache
- `redisCache` - Redis Cache

### Event Hubs / Service Bus
- `namespace` - Event Hubs or Service Bus namespace

### PostgreSQL / MySQL
- `postgresqlServer` - PostgreSQL server
- `mysqlServer` - MySQL server

### Azure Search
- `searchService` - Azure Cognitive Search

## Private DNS Zone Configuration

### Required DNS Zones per Service

```hcl
# Storage Account - Blob
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

# Storage Account - File
resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

# Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.main.name
}

# SQL Database
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

# Cosmos DB - SQL API
resource "azurerm_private_dns_zone" "cosmos_sql" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

# App Service
resource "azurerm_private_dns_zone" "appservice" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.main.name
}

# Container Registry
resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.main.name
}

# Redis Cache
resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

# PostgreSQL
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

# MySQL
resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

# Link DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "link-to-vnet"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.networking.vnet_id
}
```

## Complete Example with DNS

```hcl
# 1. Create Private DNS Zone
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# 2. Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.networking.vnet_id
  tags                  = var.tags
}

# 3. Create Private Endpoint
module "private_endpoint_storage" {
  source = "../../modules/private-endpoints"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  private_connection_resource_id = module.storage_account.storage_account_id
  subresource_names              = ["blob"]
  subnet_id                      = module.networking.subnet_ids["data"]
  private_dns_zone_ids          = [azurerm_private_dns_zone.blob.id]
  endpoint_name                  = "storage-blob"

  tags = var.tags
}
```

## Network Requirements

### Subnet Configuration

Private endpoints require a dedicated subnet with specific settings:

```hcl
# In your networking module
subnets = {
  privatelink = {
    address_prefix = "10.0.10.0/24"
    
    # IMPORTANT: Disable private endpoint network policies
    private_endpoint_network_policies_enabled = false
    
    # Optional: Service endpoints (not required but can be used together)
    service_endpoints = []
  }
}
```

### Network Security Groups

NSGs can be applied to private endpoint subnets:

```hcl
resource "azurerm_network_security_group" "privatelink" {
  name                = "nsg-privatelink-${var.customer_short_name}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow inbound from application subnets
  security_rule {
    name                       = "AllowAppSubnets"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = ["10.0.2.0/24", "10.0.3.0/24"]
    destination_address_prefix = "*"
  }
}
```

## Common Deployment Patterns

### Pattern 1: Secure All PaaS Services

```hcl
# Deploy all resources without public access
module "storage_account" {
  source = "../../modules/storage-account"
  # ...
  public_network_access_enabled = false
}

module "key_vault" {
  source = "../../modules/key-vault"
  # ...
  public_network_access_enabled = false
}

module "sql_database" {
  source = "../../modules/sql-database"
  # ...
  public_network_access_enabled = false
}

# Create private endpoints for each
module "pe_storage" { /* ... */ }
module "pe_keyvault" { /* ... */ }
module "pe_sql" { /* ... */ }
```

### Pattern 2: Hub-Spoke with Centralized DNS

```hcl
# Hub VNet (Shared Services)
# - Private DNS zones created here
# - DNS zones linked to Hub VNet

# Spoke VNets (Workloads)
# - Private endpoints created here
# - VNet peering to Hub for DNS resolution
# - Private DNS zone links to Spoke VNets

# Benefits:
# - Centralized DNS management
# - Reduced DNS zone duplication
# - Consistent resolution across all spokes
```

### Pattern 3: Multi-Region with Global Services

```hcl
# Region 1 (East US)
module "pe_storage_eus" {
  source = "../../modules/private-endpoints"
  location = "eastus"
  private_connection_resource_id = module.storage_account.storage_account_id
  # ...
}

# Region 2 (West Europe)
module "pe_storage_weu" {
  source = "../../modules/private-endpoints"
  location = "westeurope"
  private_connection_resource_id = module.storage_account.storage_account_id
  # ...
}

# Same DNS zones can be used across regions
# Just link them to both regional VNets
```

## Security Best Practices

### 1. Disable Public Access

Always disable public network access when using private endpoints:

```hcl
public_network_access_enabled = false
```

### 2. Use Network Security Groups

Apply NSGs to control traffic to private endpoints:

```hcl
# Only allow specific source subnets
source_address_prefixes = ["10.0.2.0/24"]  # App subnet only
```

### 3. Enable DNS Integration

Always configure Private DNS zones for automatic name resolution:

```hcl
private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
```

### 4. Use Dedicated Subnets

Create separate subnets for private endpoints:

```hcl
privatelink = { address_prefix = "10.0.10.0/24" }
```

### 5. Implement Least Privilege

Use RBAC to control who can create/modify private endpoints:

```hcl
# Network Contributor for private endpoint subnet only
# Not full Virtual Network Contributor
```

## Testing Private Endpoint Connectivity

### From Azure VM

```bash
# Test DNS resolution
nslookup mystorageaccount.blob.core.windows.net

# Should return private IP (10.x.x.x), not public IP

# Test connectivity
curl https://mystorageaccount.blob.core.windows.net

# Should connect successfully via private IP
```

### From PowerShell

```powershell
# Resolve DNS
Resolve-DnsName mystorageaccount.blob.core.windows.net

# Test HTTPS connectivity
Test-NetConnection mystorageaccount.blob.core.windows.net -Port 443

# Should show TcpTestSucceeded: True with private IP
```

### Verify Private IP Assignment

```bash
# Using Azure CLI
az network private-endpoint show \
  --name pep-stblob-contoso-prod-eus-001 \
  --resource-group rg-contoso-prod-eus-001 \
  --query 'customDnsConfigs[0].ipAddresses[0]'
```

## Cost Considerations

### Private Endpoint Costs

- **Private Endpoint**: ~$7.30/month per endpoint
- **Inbound Data**: $0.01 per GB
- **Outbound Data**: Free

### Example Monthly Costs

```
Basic Setup (5 endpoints):
- Storage (blob, file)
- Key Vault
- SQL Database
- Cosmos DB
Total: 5 × $7.30 = $36.50/month

Enterprise Setup (15 endpoints):
- Multiple services across dev/staging/prod
Total: 15 × $7.30 = $109.50/month
```

💡 **Tip**: One private endpoint per subresource. If you need blob AND file storage, that's 2 endpoints.

## Troubleshooting

### DNS Resolution Issues

**Problem**: Name resolves to public IP instead of private IP

**Solutions**:
1. Verify Private DNS zone is created and linked to VNet
2. Check DNS zone name matches service type exactly
3. Ensure VM is using Azure-provided DNS (168.63.129.16)
4. Wait 2-3 minutes for DNS propagation

```bash
# Check DNS server
cat /etc/resolv.conf  # Should show 168.63.129.16

# Flush DNS cache
sudo systemd-resolve --flush-caches
```

### Connection Refused

**Problem**: Cannot connect to service via private endpoint

**Solutions**:
1. Verify NSG rules allow traffic from source subnet
2. Check private endpoint is in "Approved" state
3. Verify subnet has `private_endpoint_network_policies_enabled = false`
4. Ensure service has `public_network_access_enabled = false`

### Manual Approval Pending

**Problem**: Private endpoint stuck in "Pending" state

**Solution**: Approve the connection manually:

```bash
az network private-endpoint-connection approve \
  --id /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{account}/privateEndpointConnections/{connection}
```

## When to Use Private Endpoints

### ✅ Use Private Endpoints When:
- **Compliance requirements** mandate no public internet exposure
- **Sensitive data** is stored in Azure PaaS services
- **Hub-spoke architecture** with centralized security
- **Hybrid connectivity** with ExpressRoute or VPN
- **Zero Trust security model** implementation

### ❌ Consider Alternatives When:
- **Simple dev/test** environments (use service endpoints or public access with firewall)
- **Cost-sensitive** scenarios with many services (service endpoints are free)
- **Internet-facing** services that need public access anyway

## Private Endpoints vs Service Endpoints

| Feature | Private Endpoints | Service Endpoints |
|---------|-------------------|-------------------|
| **Cost** | ~$7.30/month each | Free |
| **IP Address** | Private IP in your VNet | Service keeps public IP |
| **DNS Required** | Yes, Private DNS zones | No |
| **On-Premises Access** | Yes (via VPN/ExpressRoute) | No |
| **NSG Support** | Yes | Yes |
| **Best For** | Production, secure workloads | Dev/test, cost optimization |

## Dependencies

This module requires:
- Virtual Network with appropriate subnet
- (Recommended) Private DNS zones for name resolution
- Target resource (Storage, Key Vault, SQL, etc.)

## Integration Example

```hcl
# Create resources
module "networking" {
  source = "../../modules/networking"
  
  subnets = {
    data = {
      address_prefix = "10.0.5.0/24"
    }
    privatelink = {
      address_prefix = "10.0.10.0/24"
      private_endpoint_network_policies_enabled = false
    }
  }
}

module "storage_account" {
  source = "../../modules/storage-account"
  public_network_access_enabled = false
}

# Create DNS zone
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.networking.vnet_id
}

# Create private endpoint
module "private_endpoint" {
  source = "../../modules/private-endpoints"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  private_connection_resource_id = module.storage_account.storage_account_id
  subresource_names              = ["blob"]
  subnet_id                      = module.networking.subnet_ids["privatelink"]
  private_dns_zone_ids          = [azurerm_private_dns_zone.blob.id]
  endpoint_name                  = "storage-blob"
  
  tags = var.tags
}
```

## Deployment Control

Add to your deployment's `variables.tf`:

```hcl
variable "enable_private_endpoints" {
  description = "Enable private endpoints for secure connectivity"
  type        = bool
  default     = false
}

variable "private_endpoint_services" {
  description = "List of services requiring private endpoints"
  type        = list(string)
  default     = []
  # Example: ["storage-blob", "keyvault", "sql"]
}
```

## Additional Resources

- [Private Endpoint Documentation](https://docs.microsoft.com/azure/private-link/private-endpoint-overview)
- [Private DNS Zones](https://docs.microsoft.com/azure/private-link/private-endpoint-dns)
- [Network Security](https://docs.microsoft.com/azure/private-link/private-endpoint-overview#network-security)
- [Pricing Calculator](https://azure.microsoft.com/pricing/details/private-link/)

---

**Status**: ✅ README Template  
**Complexity**: ⭐⭐⭐ (Medium - DNS configuration is the tricky part)  
**Cost Impact**: ~$7.30/month per endpoint  
**Security**: ⭐⭐⭐⭐⭐ Essential for production workloads
