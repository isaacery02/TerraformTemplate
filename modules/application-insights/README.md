# Azure Application Insights Module

This module creates an Azure Application Insights resource for Application Performance Monitoring (APM) and telemetry collection.

## Overview

Application Insights is Azure's APM solution that provides deep visibility into your application's performance, usage patterns, failures, and dependencies. It automatically collects telemetry from your applications without code changes (for supported platforms).

## Features

- 📊 Real-time application monitoring
- 🔍 Automatic dependency tracking
- 🐛 Exception and failure analysis
- ⚡ Performance profiling
- 📈 Custom metrics and events
- 🌐 Distributed tracing
- 🎯 User analytics
- 🚨 Smart detection and alerts
- 📱 Support for web, mobile, and server apps

## Module Structure

```
modules/application-insights/
├── main.tf          # Application Insights resource
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
└── README.md        # This file
```

## Simple Usage Example

### Basic Application Insights

```hcl
module "application_insights" {
  source = "../../modules/application-insights"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  # Link to Log Analytics workspace
  workspace_id = module.log_analytics.workspace_id

  # Application type
  application_type = "web"  # web, ios, java, other, phone, store

  tags = var.tags
}
```

### Integrated with App Service

```hcl
# Create Application Insights
module "app_insights" {
  source = "../../modules/application-insights"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = module.log_analytics.workspace_id
  application_type    = "web"

  # Optional settings
  daily_data_cap_in_gb = 10
  retention_in_days    = 90

  tags = var.tags
}

# Configure App Service with Application Insights
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.customer_short_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  app_settings = {
    # Application Insights configuration
    "APPLICATIONINSIGHTS_CONNECTION_STRING"             = module.app_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"        = "~3"
    "APPINSIGHTS_INSTRUMENTATIONKEY"                    = module.app_insights.instrumentation_key
    "APPINSIGHTS_PROFILERFEATURE_VERSION"              = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"              = "1.0.0"
    "DiagnosticServices_EXTENSION_VERSION"              = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"           = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"                = "disabled"
    "XDT_MicrosoftApplicationInsights_Mode"             = "recommended"
    "XDT_MicrosoftApplicationInsights_BaseExtensions"   = "disabled"
  }

  site_config {
    # ... other config
  }
}
```

### Multiple Application Insights (Microservices)

```hcl
# Frontend Application
module "app_insights_frontend" {
  source = "../../modules/application-insights"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = module.log_analytics.workspace_id
  application_type    = "web"
  
  app_name = "frontend"

  tags = merge(var.tags, {
    Component = "Frontend"
  })
}

# Backend API
module "app_insights_api" {
  source = "../../modules/application-insights"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = module.log_analytics.workspace_id
  application_type    = "web"
  
  app_name = "api"

  tags = merge(var.tags, {
    Component = "API"
  })
}

# Background Worker
module "app_insights_worker" {
  source = "../../modules/application-insights"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = module.log_analytics.workspace_id
  application_type    = "other"
  
  app_name = "worker"

  tags = merge(var.tags, {
    Component = "Worker"
  })
}
```

## Resource Naming

```
appi-{app-name}-{customer-short-name}-{environment}-{region-code}-{instance}
```

### Examples
- Web App: `appi-web-contoso-prod-eus-001`
- API: `appi-api-contoso-prod-eus-001`
- Mobile: `appi-mobile-contoso-prod-eus-001`
- Worker: `appi-worker-contoso-prod-eus-001`

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `customer_short_name` | string | Customer identifier (3-8 chars) |
| `environment` | string | Environment (dev, staging, prod) |
| `location` | string | Azure region |
| `location_code` | string | Short region code |
| `resource_group_name` | string | Resource group name |
| `workspace_id` | string | Log Analytics workspace ID |
| `application_type` | string | Type of application being monitored |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `app_name` | string | `""` | Application name for multi-app scenarios |
| `daily_data_cap_in_gb` | number | `null` | Daily ingestion cap in GB |
| `daily_data_cap_notifications_disabled` | bool | `false` | Disable cap notifications |
| `retention_in_days` | number | `90` | Data retention period (30-730 days) |
| `sampling_percentage` | number | `100` | Telemetry sampling percentage |
| `disable_ip_masking` | bool | `false` | Store full IP addresses |
| `local_authentication_disabled` | bool | `false` | Disable API key auth |
| `internet_ingestion_enabled` | bool | `true` | Allow ingestion from internet |
| `internet_query_enabled` | bool | `true` | Allow queries from internet |

## Application Types

| Type | Description | Use Case |
|------|-------------|----------|
| `web` | Web application | ASP.NET, Java, Node.js, Python web apps |
| `ios` | iOS application | Native iOS apps |
| `java` | Java application | Java services, Spring Boot |
| `other` | Other application | Background services, workers, console apps |
| `phone` | Phone application | Mobile apps (generic) |
| `store` | Store application | Windows Store apps |

## Outputs

| Output | Description |
|--------|-------------|
| `instrumentation_key` | Instrumentation key (legacy) |
| `connection_string` | Connection string (recommended) |
| `app_id` | Application ID |
| `app_insights_id` | Resource ID |
| `app_insights_name` | Resource name |

## SDK Integration Examples

### .NET / ASP.NET Core

```csharp
// Program.cs or Startup.cs
builder.Services.AddApplicationInsightsTelemetry(new ApplicationInsightsServiceOptions
{
    ConnectionString = Environment.GetEnvironmentVariable("APPLICATIONINSIGHTS_CONNECTION_STRING")
});

// Or in appsettings.json
{
  "ApplicationInsights": {
    "ConnectionString": "InstrumentationKey=xxx;IngestionEndpoint=xxx"
  }
}
```

### Node.js

```javascript
const appInsights = require("applicationinsights");
appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true, true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true)
    .setUseDiskRetryCaching(true)
    .start();
```

### Python

```python
from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.ext.azure import metrics_exporter
import logging

connection_string = os.environ.get('APPLICATIONINSIGHTS_CONNECTION_STRING')

# Logging
logger = logging.getLogger(__name__)
logger.addHandler(AzureLogHandler(connection_string=connection_string))

# Metrics
exporter = metrics_exporter.new_metrics_exporter(connection_string=connection_string)
```

### Java (Spring Boot)

```xml
<!-- pom.xml -->
<dependency>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>applicationinsights-spring-boot-starter</artifactId>
    <version>3.4.18</version>
</dependency>
```

```yaml
# application.yml
azure:
  application-insights:
    connection-string: ${APPLICATIONINSIGHTS_CONNECTION_STRING}
```

## Azure Functions Integration

```hcl
resource "azurerm_linux_function_app" "main" {
  name                = "func-${var.customer_short_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  app_settings = {
    # Application Insights for Functions
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.app_insights.connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = module.app_insights.instrumentation_key
    
    # Other settings...
  }

  site_config {
    application_insights_connection_string = module.app_insights.connection_string
    application_insights_key               = module.app_insights.instrumentation_key
  }
}
```

## Container Apps Integration

```hcl
resource "azurerm_container_app" "main" {
  name                         = "ca-${var.customer_short_name}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "app"
      image  = "myapp:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = module.app_insights.connection_string
      }
    }
  }
}
```

## Common Queries (Kusto/KQL)

### Failed Requests
```kusto
requests
| where success == false
| summarize count() by resultCode, name
| order by count_ desc
```

### Slowest Operations
```kusto
requests
| summarize avg(duration), percentile(duration, 95) by name
| order by avg_duration desc
| take 10
```

### Exception Analysis
```kusto
exceptions
| summarize count() by type, outerMessage
| order by count_ desc
```

### Dependency Failures
```kusto
dependencies
| where success == false
| summarize count() by target, type, name
| order by count_ desc
```

### User Sessions
```kusto
pageViews
| summarize sessions = dcount(session_Id), pageviews = count() by bin(timestamp, 1h)
| render timechart
```

## Smart Detection & Alerts

Application Insights includes built-in anomaly detection:

### Automatic Alerts For:
- Failure rate increases
- Slow page load times
- Memory leaks
- Degraded dependency performance
- Trace severity anomalies

### Custom Alert Example

```hcl
resource "azurerm_monitor_metric_alert" "app_response_time" {
  name                = "alert-response-time-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [module.app_insights.app_insights_id]
  description         = "Alert when response time exceeds threshold"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 3000  # 3 seconds
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

## Data Retention & Costs

### Retention Options
- **30 days**: Free (included)
- **90 days**: ~$0.12/GB/month
- **180 days**: ~$0.12/GB/month
- **365 days**: ~$0.12/GB/month
- **730 days**: ~$0.12/GB/month (max)

### Ingestion Costs
- **First 5 GB/month**: Free
- **Additional data**: ~$2.30/GB

### Example Monthly Costs

```
Small App (1 GB/month):
- Ingestion: Free (under 5 GB)
- Retention (90 days): $0.12
Total: ~$0.12/month

Medium App (10 GB/month):
- Ingestion: $11.50 (5 GB × $2.30)
- Retention (90 days): $1.20
Total: ~$12.70/month

Large App (100 GB/month):
- Ingestion: $218.50 (95 GB × $2.30)
- Retention (90 days): $12
Total: ~$230.50/month
```

### Cost Optimization

```hcl
# Set daily cap to control costs
daily_data_cap_in_gb = 5  # Stop ingestion after 5 GB/day

# Use sampling to reduce data volume
sampling_percentage = 50  # Collect 50% of telemetry

# Shorter retention for non-production
retention_in_days = 30  # Minimum for dev environments
```

## Performance Profiler

### Enable Profiler

```hcl
resource "azurerm_linux_web_app" "main" {
  # ...

  app_settings = {
    "APPINSIGHTS_PROFILERFEATURE_VERSION" = "1.0.0"
    "DiagnosticServices_EXTENSION_VERSION" = "~3"
  }
}
```

### View Profiler Traces
1. Navigate to Application Insights → Performance
2. Select operation
3. Click "Profiler traces"
4. Analyze method-level performance

## Snapshot Debugger

### Enable Snapshots

```hcl
resource "azurerm_linux_web_app" "main" {
  # ...

  app_settings = {
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION" = "1.0.0"
    "SnapshotDebugger_EXTENSION_VERSION" = "~2"
  }
}
```

### Collect Snapshots on Exceptions
Automatically captures full memory snapshots when exceptions occur, allowing debugging of production issues.

## Distributed Tracing

### Automatic Correlation
Application Insights automatically tracks requests across:
- HTTP/HTTPS calls
- SQL databases
- Redis cache
- Azure Storage
- Service Bus
- Event Hubs
- Cosmos DB

### Application Map
Visualize dependencies and performance:
1. Azure Portal → Application Insights
2. Click "Application Map"
3. View service topology with response times and failure rates

## Live Metrics Stream

Monitor real-time telemetry:
```
Portal → Application Insights → Live Metrics
```

View:
- Incoming request rate
- Outgoing request duration
- Failure rates
- Server CPU/memory
- Custom metrics
- Sample telemetry

## Availability Tests

### URL Ping Test
```hcl
resource "azurerm_application_insights_standard_web_test" "main" {
  name                    = "test-availability-${var.environment}"
  resource_group_name     = azurerm_resource_group.main.name
  location                = var.location
  application_insights_id = module.app_insights.app_insights_id
  geo_locations           = ["us-va-ash-azr", "us-ca-sjc-azr", "emea-nl-ams-azr"]
  
  request {
    url = "https://app-${var.customer_short_name}-${var.environment}.azurewebsites.net"
  }

  validation_rules {
    expected_status_code = 200
  }
}
```

### Multi-Step Web Test
Create complex test scenarios:
- Login flows
- Shopping cart operations
- Form submissions

## Security Best Practices

### 1. Use Connection String (Not Instrumentation Key)
```hcl
# ✅ Modern approach
APPLICATIONINSIGHTS_CONNECTION_STRING = module.app_insights.connection_string

# ❌ Legacy approach
APPINSIGHTS_INSTRUMENTATIONKEY = module.app_insights.instrumentation_key
```

### 2. Disable Public Access (Optional)
```hcl
internet_ingestion_enabled = false
internet_query_enabled     = false
```

### 3. Disable API Key Authentication
```hcl
local_authentication_disabled = true
```

### 4. Enable IP Masking (GDPR)
```hcl
disable_ip_masking = false  # Default - masks last octet
```

### 5. Use Managed Identity
Configure apps to use managed identity for authentication instead of connection strings.

## Troubleshooting

### No Telemetry Appearing

**Causes**:
1. Incorrect connection string
2. Firewall blocking ingestion endpoint
3. SDK not installed or configured
4. Sampling set too low

**Solutions**:
```bash
# Verify connection string
echo $APPLICATIONINSIGHTS_CONNECTION_STRING

# Test ingestion endpoint
curl https://dc.services.visualstudio.com/v2/track

# Check SDK version
# .NET: Check NuGet packages
# Node: Check package.json
```

### High Costs / Data Volume

**Solutions**:
1. Enable sampling: `sampling_percentage = 50`
2. Set daily cap: `daily_data_cap_in_gb = 10`
3. Reduce retention: `retention_in_days = 30`
4. Filter telemetry in SDK
5. Use telemetry processors to exclude noise

### Delayed Telemetry

Telemetry can take 2-5 minutes to appear. Use Live Metrics for real-time view.

## When to Use Application Insights

### ✅ Use Application Insights For:
- Production applications requiring APM
- Performance monitoring and optimization
- Exception tracking and debugging
- User analytics and behavior
- Distributed tracing across microservices
- Availability monitoring
- Custom metrics and events

### 🤔 Consider Alternatives:
- **Azure Monitor Logs**: Infrastructure and resource-level monitoring
- **Azure Monitor Metrics**: Resource metrics only
- **Third-party APM**: Datadog, New Relic (if already standardized)

## Application Insights vs. Log Analytics

| Feature | Application Insights | Log Analytics |
|---------|---------------------|---------------|
| **Purpose** | Application performance | Infrastructure monitoring |
| **Data** | Requests, exceptions, traces | Resource logs, metrics |
| **Tracing** | Distributed tracing | Basic correlation |
| **User Analytics** | Yes | No |
| **Cost** | Per GB ingested | Per GB ingested |
| **Integration** | App SDKs | Diagnostic settings |

💡 **Best Practice**: Use both together. App Insights stores data in Log Analytics workspace.

## Dependencies

This module requires:
- Log Analytics Workspace (recommended, not required for classic mode)
- Application code instrumented with SDK (for custom telemetry)

## Integration Example

```hcl
# Create Log Analytics workspace
module "log_analytics" {
  source = "../../modules/log-analytics"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  tags = var.tags
}

# Create Application Insights
module "app_insights" {
  source = "../../modules/application-insights"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  workspace_id     = module.log_analytics.workspace_id
  application_type = "web"
  
  # Production settings
  retention_in_days    = 90
  daily_data_cap_in_gb = 10
  
  tags = var.tags
}

# Use in App Service
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.customer_short_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.app_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }
}
```

## Additional Resources

- [Application Insights Documentation](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [SDKs and Configuration](https://docs.microsoft.com/azure/azure-monitor/app/platforms)
- [Sampling Best Practices](https://docs.microsoft.com/azure/azure-monitor/app/sampling)
- [Pricing Calculator](https://azure.microsoft.com/pricing/details/monitor/)

---

**Status**: ✅ README Template  
**Complexity**: ⭐⭐ (Easy to moderate - SDK integration is straightforward)  
**Cost**: First 5GB free, then ~$2.30/GB  
**Essential For**: Production applications requiring observability
