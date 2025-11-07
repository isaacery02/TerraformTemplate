# Azure API Management (APIM) Module

This module creates an Azure API Management service for publishing, securing, transforming, and managing APIs at scale.

## Overview

Azure API Management is a complete API gateway solution that sits between your backend services and external consumers. It provides a unified experience for publishing, securing, transforming, maintaining, and monitoring APIs.

## Features

- 🌐 API gateway and proxy
- 🔐 Authentication & authorization (OAuth2, JWT, API keys, certificates)
- 🎯 Rate limiting and quotas
- 📊 Analytics and monitoring
- 🔄 Request/response transformation
- 📝 Developer portal (self-service API discovery)
- 🌍 Multi-region deployment
- 💾 Response caching
- 🔀 Load balancing across backends
- 🛡️ DDoS protection

## Module Structure

```
modules/api-management/
├── main.tf          # APIM service and configuration
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
└── README.md        # This file
```

## Simple Usage Example

### Basic APIM (Development)

```hcl
module "api_management" {
  source = "../../modules/api-management"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  # Publisher information (required)
  publisher_name  = "Contoso Ltd"
  publisher_email = "api@contoso.com"

  # SKU
  sku_name = "Developer_1"  # Developer tier with 1 unit

  tags = var.tags
}
```

### Production APIM with VNet Integration

```hcl
module "api_management" {
  source = "../../modules/api-management"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  publisher_name  = "Contoso Ltd"
  publisher_email = "api@contoso.com"

  # Production SKU
  sku_name = "Premium_1"  # Premium tier with 1 unit

  # VNet integration (Premium only)
  virtual_network_type = "Internal"  # Internal or External
  subnet_id            = module.networking.subnet_ids["apim"]

  # Identity
  identity_type = "SystemAssigned"

  # Additional zones for HA (Premium only)
  availability_zones = ["1", "2", "3"]

  # Developer portal
  public_network_access_enabled = true

  tags = var.tags
}
```

## Resource Naming

```
apim-{customer-short-name}-{environment}-{region-code}-{instance}
```

### Examples
- Development: `apim-contoso-dev-eus-001`
- Production: `apim-contoso-prod-eus-001`
- Staging: `apim-contoso-staging-weu-001`

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `customer_short_name` | string | Customer identifier (3-8 chars) |
| `environment` | string | Environment (dev, staging, prod) |
| `location` | string | Azure region |
| `location_code` | string | Short region code |
| `resource_group_name` | string | Resource group name |
| `publisher_name` | string | Publisher name for developer portal |
| `publisher_email` | string | Publisher email for notifications |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `sku_name` | string | `"Developer_1"` | SKU (Consumption/Developer/Basic/Standard/Premium) |
| `virtual_network_type` | string | `"None"` | VNet integration (None/Internal/External) |
| `subnet_id` | string | `null` | Subnet ID for VNet integration |
| `public_network_access_enabled` | bool | `true` | Enable public access |
| `identity_type` | string | `null` | Managed identity (SystemAssigned/UserAssigned) |
| `availability_zones` | list(string) | `[]` | Availability zones (Premium only) |
| `min_api_version` | string | `null` | Minimum API version supported |

## SKU Comparison

| Tier | Use Case | SLA | VNet | Multi-Region | Price/Month |
|------|----------|-----|------|--------------|-------------|
| **Consumption** | Serverless, pay-per-call | None | ❌ | ❌ | ~$0.035/10K calls |
| **Developer** | Dev/test only | None | ❌ | ❌ | ~$50 |
| **Basic** | Small workloads | 99.95% | ❌ | ❌ | ~$150 |
| **Standard** | Production | 99.95% | ❌ | ❌ | ~$730 |
| **Premium** | Enterprise | 99.99% | ✅ | ✅ | ~$2,920 |

### SKU Details

#### Consumption
- **Best for**: Serverless apps, event-driven APIs, dev/test
- **Limitations**: No VNet, no custom domains, no caching, limited policies
- **Pricing**: $3.50 per 1M calls + $0.035 per 10K calls

#### Developer (Dev/Test Only)
- **Best for**: Development and testing
- **Features**: Full policy support, no SLA
- **Limitations**: Not for production use, 1 unit only, no scale
- **Pricing**: ~$50/month

#### Basic
- **Best for**: Small production APIs
- **Scale**: 2 units max
- **Throughput**: ~1K requests/sec per unit
- **Pricing**: ~$150/month per unit

#### Standard
- **Best for**: Standard production workloads
- **Scale**: 4 units max
- **Throughput**: ~2.5K requests/sec per unit
- **Pricing**: ~$730/month per unit

#### Premium
- **Best for**: Enterprise, multi-region, VNet integration
- **Scale**: 12+ units
- **Features**: Multi-region, VNet, availability zones, self-hosted gateway
- **Pricing**: ~$2,920/month per unit

## Outputs

| Output | Description |
|--------|-------------|
| `apim_id` | API Management service ID |
| `apim_name` | API Management service name |
| `gateway_url` | API gateway URL |
| `portal_url` | Developer portal URL |
| `management_api_url` | Management API URL |
| `scm_url` | SCM endpoint URL |
| `public_ip_addresses` | Public IP addresses |
| `private_ip_addresses` | Private IP addresses |
| `principal_id` | Managed identity principal ID |

## API Configuration Example

### Add Backend API

```hcl
# Backend API (App Service, Function, etc.)
resource "azurerm_api_management_backend" "backend" {
  name                = "backend-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = module.api_management.apim_name
  protocol            = "http"
  url                 = "https://backend-${var.customer_short_name}-${var.environment}.azurewebsites.net"
  
  credentials {
    header = {
      "x-api-key" = "@(context.Variables.GetValueOrDefault('backend-key'))"
    }
  }
}

# API definition
resource "azurerm_api_management_api" "main" {
  name                = "products-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = module.api_management.apim_name
  revision            = "1"
  display_name        = "Products API"
  path                = "products"
  protocols           = ["https"]
  service_url         = "https://backend-${var.customer_short_name}-${var.environment}.azurewebsites.net"

  subscription_required = true
}

# API operation
resource "azurerm_api_management_api_operation" "get_products" {
  operation_id        = "get-products"
  api_name            = azurerm_api_management_api.main.name
  api_management_name = module.api_management.apim_name
  resource_group_name = azurerm_resource_group.main.name
  display_name        = "Get Products"
  method              = "GET"
  url_template        = "/"
  description         = "Retrieve list of products"

  response {
    status_code = 200
    description = "Success"
  }
}
```

## Policy Examples

### Rate Limiting (Per Subscription)

```xml
<policies>
    <inbound>
        <rate-limit calls="100" renewal-period="60" />
        <quota calls="10000" renewal-period="86400" />
    </inbound>
</policies>
```

### JWT Validation (OAuth2)

```xml
<policies>
    <inbound>
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
            <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration" />
            <audiences>
                <audience>api://{app-id}</audience>
            </audiences>
            <required-claims>
                <claim name="roles" match="any">
                    <value>Admin</value>
                    <value>User</value>
                </claim>
            </required-claims>
        </validate-jwt>
    </inbound>
</policies>
```

### Request Transformation

```xml
<policies>
    <inbound>
        <set-header name="X-Forwarded-For" exists-action="override">
            <value>@(context.Request.IpAddress)</value>
        </set-header>
        <set-header name="X-Request-Id" exists-action="override">
            <value>@(Guid.NewGuid().ToString())</value>
        </set-header>
        <rewrite-uri template="/api/v2/{path}" />
    </inbound>
</policies>
```

### Response Caching

```xml
<policies>
    <inbound>
        <cache-lookup vary-by-developer="false" vary-by-developer-groups="false">
            <vary-by-query-parameter>category</vary-by-query-parameter>
        </cache-lookup>
    </inbound>
    <outbound>
        <cache-store duration="3600" />
    </outbound>
</policies>
```

### IP Filtering

```xml
<policies>
    <inbound>
        <ip-filter action="allow">
            <address-range from="192.168.1.0" to="192.168.1.255" />
            <address>10.0.0.1</address>
        </ip-filter>
    </inbound>
</policies>
```

### Mock Responses (Testing)

```xml
<policies>
    <inbound>
        <mock-response status-code="200" content-type="application/json"/>
    </inbound>
</policies>
```

## Authentication Methods

### 1. Subscription Keys (Built-in)

```bash
# Default APIM authentication
curl -H "Ocp-Apim-Subscription-Key: {key}" https://apim-contoso-prod-eus-001.azure-api.net/products
```

### 2. OAuth 2.0 / Azure AD

```xml
<validate-jwt header-name="Authorization">
    <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration" />
    <audiences>
        <audience>api://{app-id}</audience>
    </audiences>
</validate-jwt>
```

### 3. Client Certificates

```xml
<choose>
    <when condition="@(context.Request.Certificate == null || context.Request.Certificate.Thumbprint != "desired-thumbprint")">
        <return-response>
            <set-status code="403" reason="Invalid client certificate" />
        </return-response>
    </when>
</choose>
```

### 4. Basic Authentication

```xml
<authentication-basic username="{{username}}" password="{{password}}" />
```

### 5. Managed Identity (to backend)

```xml
<authentication-managed-identity resource="https://management.azure.com/" />
```

## VNet Integration

### External Mode (DMZ Pattern)

```hcl
module "api_management" {
  source = "../../modules/api-management"
  
  # ...
  
  sku_name             = "Premium_1"
  virtual_network_type = "External"  # Public gateway IP, private backends
  subnet_id            = module.networking.subnet_ids["apim"]
}
```

**Use case**: 
- Gateway accessible from internet
- Backends are internal VNet resources
- Common for public APIs with private backends

### Internal Mode (Fully Private)

```hcl
module "api_management" {
  source = "../../modules/api-management"
  
  # ...
  
  sku_name             = "Premium_1"
  virtual_network_type = "Internal"  # Private gateway IP
  subnet_id            = module.networking.subnet_ids["apim"]
}
```

**Use case**:
- Gateway only accessible from VNet
- Backends are internal
- Common for internal APIs, B2B scenarios

### Subnet Requirements

```hcl
# Dedicated subnet for APIM
apim = {
  address_prefix = "10.0.20.0/24"  # Minimum /29, recommended /24
  
  # Required service endpoints
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.EventHub",
    "Microsoft.KeyVault"
  ]
}
```

## Multi-Region Deployment (Premium)

```hcl
resource "azurerm_api_management" "main" {
  name                = "apim-${var.customer_short_name}-${var.environment}"
  location            = "eastus"  # Primary region
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Premium_1"

  # Add secondary region
  additional_location {
    location = "westeurope"
    capacity = 1
    
    zones = ["1", "2", "3"]
    
    virtual_network_configuration {
      subnet_id = module.networking_weu.subnet_ids["apim"]
    }
  }
}
```

**Benefits**:
- Low latency globally
- High availability
- Automatic failover
- Shared configuration across regions

## Custom Domains

```hcl
resource "azurerm_api_management_custom_domain" "main" {
  api_management_id = module.api_management.apim_id

  gateway {
    host_name    = "api.contoso.com"
    key_vault_id = azurerm_key_vault_certificate.api.versionless_secret_id
  }

  developer_portal {
    host_name    = "developer.contoso.com"
    key_vault_id = azurerm_key_vault_certificate.portal.versionless_secret_id
  }

  management {
    host_name    = "management.contoso.com"
    key_vault_id = azurerm_key_vault_certificate.mgmt.versionless_secret_id
  }
}
```

## Developer Portal Configuration

### Enable OAuth2 in Portal

```hcl
resource "azurerm_api_management_openid_connect_provider" "azure_ad" {
  name                = "azure-ad"
  api_management_name = module.api_management.apim_name
  resource_group_name = azurerm_resource_group.main.name
  client_id           = azuread_application.api.application_id
  client_secret       = azuread_application_password.api.value
  display_name        = "Azure AD"
  metadata_endpoint   = "https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration"
}
```

### Customize Portal

1. Navigate to Developer Portal in Azure Portal
2. Click "Publish" after customization
3. Users can:
   - Browse APIs
   - Try APIs interactively
   - Subscribe for keys
   - View documentation

## Application Insights Integration

```hcl
resource "azurerm_api_management_logger" "app_insights" {
  name                = "appinsights-logger"
  api_management_name = module.api_management.apim_name
  resource_group_name = azurerm_resource_group.main.name

  application_insights {
    instrumentation_key = module.application_insights.instrumentation_key
  }
}

resource "azurerm_api_management_diagnostic" "main" {
  identifier          = "applicationinsights"
  api_management_name = module.api_management.apim_name
  resource_group_name = azurerm_resource_group.main.name
  api_management_logger_id = azurerm_api_management_logger.app_insights.id

  sampling_percentage       = 100.0
  always_log_errors        = true
  log_client_ip            = true
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 1024
    headers_to_log = ["Content-Type", "User-Agent"]
  }

  frontend_response {
    body_bytes = 1024
    headers_to_log = ["Content-Type"]
  }

  backend_request {
    body_bytes = 1024
    headers_to_log = ["Content-Type"]
  }

  backend_response {
    body_bytes = 1024
    headers_to_log = ["Content-Type"]
  }
}
```

## Cost Optimization

### Consumption Tier
```hcl
sku_name = "Consumption"

# Pricing:
# - First 1M calls/month: Free
# - Additional calls: $3.50 per million
# - Example: 5M calls = $14/month
```

### Developer Tier (Dev/Test)
```hcl
sku_name = "Developer_1"

# Pricing: ~$50/month
# No SLA, single unit only
```

### Right-Sizing
```hcl
# Start small, scale up
sku_name = "Basic_1"  # ~$150/month

# Monitor and scale
sku_name = "Standard_2"  # ~$1,460/month (2 units)

# Premium only when needed
sku_name = "Premium_1"  # ~$2,920/month
```

## Common Architectures

### Pattern 1: API Gateway for Microservices

```
Internet → APIM → [API 1, API 2, API 3, ...] (App Services/Functions)
```

**Benefits**:
- Single entry point
- Centralized authentication
- Rate limiting per consumer
- API versioning

### Pattern 2: Legacy Modernization

```
Internet → APIM → [New API, Legacy API] → Backends
```

**Benefits**:
- Gradual migration
- Consistent API experience
- Transform legacy responses

### Pattern 3: Partner Integration (B2B)

```
Partner → APIM (VNet Internal) → Private APIs
```

**Benefits**:
- Secure access
- Per-partner quotas
- IP filtering
- Client certificates

## Monitoring & Diagnostics

### Built-in Metrics
- Total Gateway Requests
- Successful Gateway Requests
- Failed Gateway Requests
- Capacity (CPU/memory usage)
- Request duration

### Custom Alerts

```hcl
resource "azurerm_monitor_metric_alert" "apim_capacity" {
  name                = "alert-apim-capacity"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [module.api_management.apim_id]
  description         = "Alert when APIM capacity exceeds 75%"

  criteria {
    metric_namespace = "Microsoft.ApiManagement/service"
    metric_name      = "Capacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 75
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

## Security Best Practices

### 1. Use Managed Identity
```hcl
identity_type = "SystemAssigned"
```

### 2. Enable HTTPS Only
```xml
<choose>
    <when condition="@(context.Request.OriginalUrl.Scheme != "https")">
        <return-response>
            <set-status code="403" reason="HTTPS Required" />
        </return-response>
    </when>
</choose>
```

### 3. Validate Input
```xml
<validate-content unspecified-content-type-action="prevent" max-size="102400" size-exceeded-action="prevent" errors-variable-name="requestBodyValidation">
    <content type="application/json" validate-as="json" action="prevent" />
</validate-content>
```

### 4. Use Named Values for Secrets
Store secrets in Key Vault, reference in policies:
```xml
<set-header name="X-API-Key" exists-action="override">
    <value>{{backend-api-key}}</value>
</set-header>
```

### 5. Implement Rate Limiting
```xml
<rate-limit-by-key calls="100" renewal-period="60" counter-key="@(context.Subscription.Id)" />
```

## Troubleshooting

### High Latency

**Causes**:
1. Backend performance
2. Policy overhead
3. VNet routing

**Solutions**:
- Enable response caching
- Optimize policies
- Check backend performance
- Monitor APIM capacity

### 429 (Too Many Requests)

**Causes**:
- Rate limit policies
- Quota exceeded

**Solutions**:
```xml
<retry condition="@(context.Response.StatusCode == 429)" count="3" interval="5" />
```

### 502 (Bad Gateway)

**Causes**:
- Backend unavailable
- Timeout

**Solutions**:
- Check backend health
- Increase timeout in policy
- Implement circuit breaker

## When to Use API Management

### ✅ Use APIM When:
- Publishing multiple APIs
- Need centralized API governance
- Multiple API consumers (partners, mobile apps, web)
- Rate limiting/quotas required
- API monetization
- Legacy API modernization
- Microservices architecture

### ❌ Consider Alternatives When:
- Single internal API → Use Application Gateway or direct access
- Simple proxy → Use Azure Functions Proxies or App Service
- Extremely high throughput → Consider Azure Front Door

## Dependencies

This module may require:
- Virtual Network (for VNet integration)
- Key Vault (for certificates and secrets)
- Application Insights (for monitoring)
- Log Analytics (for diagnostics)

## Integration Example

```hcl
module "api_management" {
  source = "../../modules/api-management"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  publisher_name  = "Contoso Ltd"
  publisher_email = "api@contoso.com"
  
  sku_name = var.environment == "prod" ? "Standard_1" : "Developer_1"
  
  tags = var.tags
}

# Add backend API
resource "azurerm_api_management_api" "products" {
  name                = "products-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = module.api_management.apim_name
  revision            = "1"
  display_name        = "Products API"
  path                = "products"
  protocols           = ["https"]
  service_url         = module.app_service.default_site_hostname

  subscription_required = true
}
```

## Additional Resources

- [APIM Documentation](https://docs.microsoft.com/azure/api-management/)
- [Policy Reference](https://docs.microsoft.com/azure/api-management/api-management-policies)
- [Best Practices](https://docs.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region)
- [Pricing Calculator](https://azure.microsoft.com/pricing/details/api-management/)

---

**Status**: ✅ README Template  
**Complexity**: ⭐⭐⭐⭐ (High - policies and configuration can be complex)  
**Cost**: $50-$2,920/month depending on tier  
**Essential For**: API-driven architectures, microservices, partner integrations
