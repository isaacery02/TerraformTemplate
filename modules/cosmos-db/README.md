# Azure Cosmos DB Module

This module creates an Azure Cosmos DB account with support for multiple APIs (SQL, MongoDB, Cassandra, Gremlin, Table) and global distribution.

## Overview

Azure Cosmos DB is Microsoft's globally distributed, multi-model NoSQL database service. It provides turnkey global distribution, elastic scalability, single-digit millisecond latencies, and comprehensive SLAs covering throughput, latency, availability, and consistency.

## Features

- 🌍 Global distribution (multi-region writes)
- ⚡ Single-digit millisecond latency
- 📊 Multiple data models (SQL, MongoDB, Cassandra, Gremlin, Table)
- 🔄 Automatic indexing
- 📈 Elastic scalability
- 🛡️ Enterprise-grade security
- 💾 Multiple consistency levels
- 🔒 Automatic backups
- 🌐 99.999% availability SLA

## Module Structure

```
modules/cosmos-db/
├── main.tf          # Cosmos DB account and databases
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
└── README.md        # This file
```

## Simple Usage Example

### Basic Cosmos DB (SQL API)

```hcl
module "cosmos_db" {
  source = "../../modules/cosmos-db"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  # Database configuration
  offer_type                  = "Standard"
  kind                        = "GlobalDocumentDB"  # SQL API
  enable_automatic_failover   = true
  enable_free_tier           = false

  # Consistency
  consistency_level = "Session"  # Session, Eventual, ConsistentPrefix, BoundedStaleness, Strong

  # Geo-replication
  geo_locations = [
    {
      location          = "eastus"
      failover_priority = 0
      zone_redundant    = false
    }
  ]

  tags = var.tags
}
```

### Production Cosmos DB (Multi-Region)

```hcl
module "cosmos_db" {
  source = "../../modules/cosmos-db"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = true
  enable_multiple_write_locations = true  # Multi-region writes

  # Strong consistency for production
  consistency_level                   = "BoundedStaleness"
  max_staleness_prefix                = 100000
  max_interval_in_seconds             = 300

  # Multi-region deployment
  geo_locations = [
    {
      location          = "eastus"
      failover_priority = 0
      zone_redundant    = true  # Availability zones
    },
    {
      location          = "westus"
      failover_priority = 1
      zone_redundant    = true
    },
    {
      location          = "westeurope"
      failover_priority = 2
      zone_redundant    = true
    }
  ]

  # Backup
  backup_type               = "Continuous"  # Continuous or Periodic
  continuous_backup_tier    = "Continuous30Days"

  # Network security
  public_network_access_enabled      = false
  is_virtual_network_filter_enabled  = true
  virtual_network_rules = [
    {
      subnet_id                               = module.networking.subnet_ids["data"]
      ignore_missing_vnet_service_endpoint    = false
    }
  ]

  # IP firewall
  ip_range_filter = ["104.42.195.92", "40.76.54.131"]  # Azure Portal IPs

  tags = var.tags
}
```

### MongoDB API

```hcl
module "cosmos_db_mongo" {
  source = "../../modules/cosmos-db"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  offer_type = "Standard"
  kind       = "MongoDB"  # MongoDB API
  
  # MongoDB capabilities
  capabilities = ["EnableMongo", "MongoDBv4.2"]
  
  # MongoDB-specific settings
  mongo_server_version = "4.2"  # 3.2, 3.6, 4.0, 4.2

  consistency_level = "Session"

  geo_locations = [
    {
      location          = var.location
      failover_priority = 0
      zone_redundant    = false
    }
  ]

  tags = var.tags
}
```

## Resource Naming

```
cosmos-{customer-short-name}-{environment}-{region-code}-{instance}
```

### Examples
- SQL API: `cosmos-contoso-prod-eus-001`
- MongoDB: `cosmos-mongo-contoso-prod-eus-001`
- Cassandra: `cosmos-cass-contoso-prod-eus-001`

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `customer_short_name` | string | Customer identifier (3-8 chars) |
| `environment` | string | Environment (dev, staging, prod) |
| `location` | string | Azure region (primary) |
| `location_code` | string | Short region code |
| `resource_group_name` | string | Resource group name |
| `geo_locations` | list(object) | List of regions with failover priority |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `offer_type` | string | `"Standard"` | Offer type (Standard) |
| `kind` | string | `"GlobalDocumentDB"` | API type (GlobalDocumentDB/MongoDB/Parse) |
| `consistency_level` | string | `"Session"` | Default consistency level |
| `enable_automatic_failover` | bool | `false` | Enable automatic failover |
| `enable_multiple_write_locations` | bool | `false` | Enable multi-region writes |
| `enable_free_tier` | bool | `false` | Enable free tier (400 RU/s + 25GB) |
| `backup_type` | string | `"Periodic"` | Backup type (Periodic/Continuous) |
| `public_network_access_enabled` | bool | `true` | Allow public access |
| `capabilities` | list(string) | `[]` | Additional capabilities |

## API Types (kind)

| Kind | Description | Use Case |
|------|-------------|----------|
| `GlobalDocumentDB` | SQL API (native) | Document store, JSON, SQL queries |
| `MongoDB` | MongoDB API | MongoDB compatibility |
| `Parse` | Cassandra API | Wide-column store, CQL |
| `GlobalDocumentDB` + EnableGremlin | Gremlin (Graph) | Graph database |
| `GlobalDocumentDB` + EnableTable | Table API | Key-value store, Azure Table compatibility |

## Outputs

| Output | Description |
|--------|-------------|
| `cosmos_db_id` | Cosmos DB account ID |
| `cosmos_db_name` | Cosmos DB account name |
| `endpoint` | Cosmos DB endpoint URL |
| `primary_key` | Primary master key (sensitive) |
| `secondary_key` | Secondary master key (sensitive) |
| `primary_readonly_key` | Primary readonly key (sensitive) |
| `connection_strings` | Connection strings (sensitive) |
| `primary_mongodb_connection_string` | MongoDB connection string (sensitive) |

## Consistency Levels

### Strong
- **Guarantee**: Linearizability (reads return most recent write)
- **Use case**: Financial transactions, critical data
- **Latency**: Highest
- **Availability**: Lowest (requires quorum)

### Bounded Staleness
- **Guarantee**: Reads lag behind writes by K versions or T time
- **Use case**: Gaming leaderboards, stock tickers
- **Latency**: Medium-high
- **Availability**: Medium

### Session (Default)
- **Guarantee**: Consistent within a session
- **Use case**: Most applications (shopping carts, user profiles)
- **Latency**: Medium
- **Availability**: High

### Consistent Prefix
- **Guarantee**: Reads never see out-of-order writes
- **Use case**: Social media feeds, logs
- **Latency**: Low-medium
- **Availability**: High

### Eventual
- **Guarantee**: Reads eventually consistent
- **Use case**: Analytics, non-critical data
- **Latency**: Lowest
- **Availability**: Highest

## Capabilities

```hcl
capabilities = [
  "EnableMongo",              # MongoDB API
  "EnableCassandra",          # Cassandra API
  "EnableGremlin",            # Gremlin (Graph) API
  "EnableTable",              # Table API
  "EnableServerless",         # Serverless mode
  "EnableAggregationPipeline",# MongoDB aggregation
  "mongoEnableDocLevelTTL",   # Document TTL for MongoDB
  "DisableRateLimitingResponses",  # Disable 429 responses
  "AllowSelfServeUpgradeToMongo36"  # MongoDB version upgrade
]
```

## Database Creation Examples

### SQL API Database & Container

```hcl
# Create database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "products"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = module.cosmos_db.cosmos_db_name
  
  # Throughput (RU/s)
  throughput = 400  # Minimum for shared throughput
}

# Create container
resource "azurerm_cosmosdb_sql_container" "items" {
  name                = "items"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = module.cosmos_db.cosmos_db_name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  
  partition_key_path    = "/category"
  partition_key_version = 2
  
  # Container-level throughput
  throughput = 400
  
  # Indexing policy
  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }

  # TTL (time to live)
  default_ttl = -1  # -1 = off, 0 = on with no default, >0 = default in seconds
}
```

### MongoDB Database & Collection

```hcl
resource "azurerm_cosmosdb_mongo_database" "main" {
  name                = "appdb"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = module.cosmos_db.cosmos_db_name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "users" {
  name                = "users"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = module.cosmos_db.cosmos_db_name
  database_name       = azurerm_cosmosdb_mongo_database.main.name

  shard_key    = "userId"
  throughput   = 400

  index {
    keys   = ["_id"]
    unique = true
  }

  index {
    keys   = ["email"]
    unique = true
  }
}
```

### Cassandra Keyspace & Table

```hcl
resource "azurerm_cosmosdb_cassandra_keyspace" "main" {
  name                = "store"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = module.cosmos_db.cosmos_db_name
  throughput          = 400
}

resource "azurerm_cosmosdb_cassandra_table" "products" {
  name                = "products"
  cassandra_keyspace_id = azurerm_cosmosdb_cassandra_keyspace.main.id

  schema {
    column {
      name = "product_id"
      type = "uuid"
    }
    column {
      name = "name"
      type = "text"
    }
    column {
      name = "price"
      type = "decimal"
    }

    partition_key {
      name = "product_id"
    }
  }
}
```

## Connection String Examples

### SQL API (.NET)

```csharp
using Microsoft.Azure.Cosmos;

var client = new CosmosClient(
    accountEndpoint: "https://cosmos-contoso-prod-eus-001.documents.azure.com:443/",
    authKeyOrResourceToken: "<primary-key>"
);

var database = client.GetDatabase("products");
var container = database.GetContainer("items");

// Query
var query = container.GetItemQueryIterator<Product>("SELECT * FROM c WHERE c.category = 'electronics'");
```

### MongoDB (Node.js)

```javascript
const { MongoClient } = require('mongodb');

const uri = process.env.COSMOS_MONGODB_CONNECTION_STRING;
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  ssl: true
});

await client.connect();
const database = client.db('appdb');
const collection = database.collection('users');

const user = await collection.findOne({ email: 'user@example.com' });
```

### Python (pymongo)

```python
from pymongo import MongoClient

uri = os.environ.get('COSMOS_MONGODB_CONNECTION_STRING')
client = MongoClient(uri, ssl=True, ssl_cert_reqs='CERT_REQUIRED')

db = client['appdb']
users = db['users']

user = users.find_one({'email': 'user@example.com'})
```

## Throughput (RU/s)

### Request Units Explained
1 RU = cost to read 1 KB document by ID
- **1 KB read by ID**: 1 RU
- **1 KB write**: ~5 RU
- **1 KB query**: 1-10+ RU (depends on complexity)
- **1 KB delete**: ~5 RU

### Provisioned Throughput

```hcl
# Database-level (shared across containers)
throughput = 400  # Minimum: 400 RU/s

# Container-level (dedicated)
throughput = 1000  # Minimum: 400 RU/s
```

### Autoscale Throughput

```hcl
autoscale_settings {
  max_throughput = 4000  # Automatically scales 0-4000 RU/s
}
```

### Serverless (On-Demand)

```hcl
capabilities = ["EnableServerless"]
# No throughput provisioning needed
# Pay per request
```

## Pricing Examples

### Provisioned Throughput
```
400 RU/s (minimum):
- Single region: $24/month
- 2 regions: $48/month
- 3 regions: $72/month

1000 RU/s:
- Single region: $58/month
- 2 regions: $116/month

Storage: $0.25/GB/month
```

### Serverless
```
100M reads (1 KB each): $0.28
100M writes (1 KB each): $1.40
Storage: $0.25/GB/month

Good for: < 400 RU/s average, variable workloads
```

### Free Tier
```
First account per subscription:
- 400 RU/s free
- 25 GB storage free
- Lasts for account lifetime
```

## Backup & Restore

### Periodic Backup (Default)

```hcl
backup {
  type                = "Periodic"
  interval_in_minutes = 240   # 4 hours (min: 60, max: 1440)
  retention_in_hours  = 720   # 30 days (min: 8, max: 720)
  storage_redundancy  = "Geo" # Geo or Local
}
```

### Continuous Backup

```hcl
backup_type            = "Continuous"
continuous_backup_tier = "Continuous30Days"  # or "Continuous7Days"

# Point-in-time restore available
# Restore from any point in last 7 or 30 days
```

**Costs**:
- Periodic: Free
- Continuous (7 days): $0.20/GB/month
- Continuous (30 days): $0.12/GB/month

## Network Security

### Private Endpoints

```hcl
module "private_endpoint_cosmos" {
  source = "../../modules/private-endpoints"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  private_connection_resource_id = module.cosmos_db.cosmos_db_id
  subresource_names              = ["Sql"]  # Sql, MongoDB, Cassandra, Gremlin, Table
  subnet_id                      = module.networking.subnet_ids["data"]
  private_dns_zone_ids          = [azurerm_private_dns_zone.cosmos.id]
  endpoint_name                  = "cosmos"

  tags = var.tags
}

# Private DNS zone
resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}
```

### VNet Service Endpoints

```hcl
virtual_network_rules = [
  {
    subnet_id                               = module.networking.subnet_ids["app"]
    ignore_missing_vnet_service_endpoint    = false
  }
]
```

### IP Firewall

```hcl
# Allow specific IPs
ip_range_filter = [
  "104.42.195.92",      # Azure Portal
  "40.76.54.131",       # Azure Portal
  "52.176.6.30",        # Azure Data Factory
  "203.0.113.10/32"     # Your office IP
]
```

## Multi-Region Configuration

### Read Regions Only

```hcl
geo_locations = [
  {
    location          = "eastus"
    failover_priority = 0    # Primary (write)
    zone_redundant    = true
  },
  {
    location          = "westus"
    failover_priority = 1    # Secondary (read)
    zone_redundant    = true
  },
  {
    location          = "westeurope"
    failover_priority = 2    # Secondary (read)
    zone_redundant    = true
  }
]
```

### Multi-Region Writes

```hcl
enable_multiple_write_locations = true

geo_locations = [
  {
    location          = "eastus"
    failover_priority = 0
    zone_redundant    = true
  },
  {
    location          = "westeurope"
    failover_priority = 0  # Same priority = both can write
    zone_redundant    = true
  }
]
```

**Benefits**:
- Low latency globally
- 99.999% write availability
- Automatic conflict resolution

**Considerations**:
- 2x cost (billed per region)
- Requires conflict resolution strategy
- Use Session or Eventual consistency

## Performance Optimization

### 1. Choose Right Partition Key
```hcl
partition_key_path = "/userId"  # High cardinality, evenly distributed
```

**Good**: userId, orderId, customerId
**Bad**: country, status, type

### 2. Optimize Indexing

```hcl
indexing_policy {
  indexing_mode = "consistent"
  
  # Exclude paths not queried
  excluded_path {
    path = "/metadata/*"
  }
  excluded_path {
    path = "/\"_etag\"/?"
  }
}
```

### 3. Use TTL for Cleanup

```hcl
default_ttl = 86400  # Documents auto-delete after 24 hours
```

### 4. Enable Autoscale

```hcl
autoscale_settings {
  max_throughput = 4000  # Scales down when not busy
}
```

### 5. Use Direct Mode

```csharp
// .NET SDK
var client = new CosmosClient(endpoint, key, new CosmosClientOptions
{
    ConnectionMode = ConnectionMode.Direct  // Faster than Gateway
});
```

## Monitoring

### Key Metrics
- Total Requests
- Total Request Units
- Data Usage
- Throttled Requests (429s)
- Availability
- Latency (P50, P99)

### Alert Example

```hcl
resource "azurerm_monitor_metric_alert" "cosmos_throttle" {
  name                = "alert-cosmos-throttle"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [module.cosmos_db.cosmos_db_id]
  description         = "Alert on high throttling rate"

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "TotalRequests"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 100

    dimension {
      name     = "StatusCode"
      operator = "Include"
      values   = ["429"]  # Rate limited
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

## Security Best Practices

### 1. Use Managed Identity
```hcl
identity {
  type = "SystemAssigned"
}
```

### 2. Disable Public Access
```hcl
public_network_access_enabled = false
```

### 3. Use Private Endpoints
See Private Endpoints section above.

### 4. Enable Firewall
```hcl
ip_range_filter = ["your-office-ip"]
```

### 5. Rotate Keys Regularly
Use Azure Key Vault to store and rotate Cosmos DB keys.

### 6. Use RBAC
Assign Cosmos DB Built-in Data Reader/Contributor roles instead of using keys.

## Troubleshooting

### 429 (Rate Limited)

**Cause**: Exceeded provisioned RU/s

**Solutions**:
1. Increase RU/s provisioning
2. Enable autoscale
3. Optimize queries
4. Implement retry logic with backoff

### High Latency

**Causes**:
- Cross-region queries
- Poor partition key choice
- Over-indexing

**Solutions**:
- Use regional endpoints
- Optimize partition key
- Tune indexing policy
- Use Direct connection mode

### High Costs

**Solutions**:
1. Use autoscale instead of provisioned
2. Consider serverless for variable workloads
3. Optimize queries to use fewer RUs
4. Clean up unused data with TTL
5. Review and optimize indexing

## When to Use Cosmos DB

### ✅ Use Cosmos DB When:
- Global distribution required
- Single-digit millisecond latency needed
- NoSQL data model fits (documents, key-value, graph)
- Elastic scale required
- 99.999% availability needed
- IoT, gaming, retail, real-time apps

### ❌ Consider Alternatives When:
- Relational data with complex joins → **Azure SQL**
- Simple caching → **Redis Cache**
- Small datasets < 1GB → **Azure Table Storage**
- Fixed schema, ACID transactions → **PostgreSQL/MySQL**
- Budget constrained → **SQL Database**

## Cosmos DB vs. Alternatives

| Feature | Cosmos DB | Azure SQL | MongoDB Atlas | DynamoDB |
|---------|-----------|-----------|---------------|----------|
| **Latency** | <10ms | 10-50ms | 10-50ms | <10ms |
| **Multi-region** | ✅ Native | ⚠️ Limited | ✅ Yes | ✅ Yes |
| **Multi-model** | ✅ 5 APIs | ❌ SQL only | ❌ Mongo only | ❌ Key-value |
| **Cost (min)** | $24/month | $5/month | $60/month | Pay-per-use |
| **Consistency** | 5 levels | Strong | Eventual | Eventual |

## Dependencies

This module optionally uses:
- Virtual Network (for VNet rules or private endpoints)
- Private DNS zones (for private endpoints)
- Key Vault (for storing connection strings)
- Application Insights (for monitoring)

## Integration Example

```hcl
# Create Cosmos DB
module "cosmos_db" {
  source = "../../modules/cosmos-db"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = true
  enable_free_tier         = var.environment == "dev"
  
  consistency_level = var.environment == "prod" ? "BoundedStaleness" : "Session"
  
  geo_locations = var.environment == "prod" ? [
    { location = "eastus", failover_priority = 0, zone_redundant = true },
    { location = "westus", failover_priority = 1, zone_redundant = true }
  ] : [
    { location = var.location, failover_priority = 0, zone_redundant = false }
  ]
  
  backup_type = var.environment == "prod" ? "Continuous" : "Periodic"
  
  tags = var.tags
}

# Store connection string in Key Vault
resource "azurerm_key_vault_secret" "cosmos_connection_string" {
  name         = "cosmos-connection-string"
  value        = module.cosmos_db.connection_strings[0]
  key_vault_id = module.key_vault.key_vault_id
}
```

## Additional Resources

- [Cosmos DB Documentation](https://docs.microsoft.com/azure/cosmos-db/)
- [Choose API Guide](https://docs.microsoft.com/azure/cosmos-db/choose-api)
- [Partition Key Best Practices](https://docs.microsoft.com/azure/cosmos-db/partitioning-overview)
- [Pricing Calculator](https://cosmos.azure.com/capacitycalculator/)

---

**Status**: ✅ README Template  
**Complexity**: ⭐⭐⭐⭐ (High - partition keys, RU calculations, consistency levels)  
**Cost**: Starting $24/month (400 RU/s, single region)  
**Essential For**: Global apps, low-latency NoSQL, IoT, gaming, real-time applications
