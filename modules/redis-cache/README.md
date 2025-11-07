# Redis Cache Module

This module creates an Azure Cache for Redis.

## Resources Created

- Azure Cache for Redis
- Firewall rules (optional)
- Private endpoint (optional)

## Usage

```hcl
module "redis_cache" {
  source = "../../modules/redis-cache"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  
  tags = var.tags
}
```

## Naming Convention

- Redis Cache: `redis-{customer}-{env}-{region}-{instance}`

## Features

- Basic, Standard, or Premium tier
- SSL/TLS enforcement
- Data persistence (Premium tier)
- Clustering (Premium tier)
- VNet integration (Premium tier)
- Geo-replication (Premium tier)
