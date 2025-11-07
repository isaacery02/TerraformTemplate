# Log Analytics Workspace Module

This module creates an Azure Log Analytics Workspace for centralized logging and monitoring.

## Resources Created

- Log Analytics Workspace
- Solutions (optional): SecurityCenter, Updates, etc.

## Usage

```hcl
module "log_analytics" {
  source = "../../modules/log-analytics"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  sku               = "PerGB2018"
  retention_in_days = 90
  
  solutions = ["SecurityCenter", "Updates", "AzureActivity"]
  
  tags = var.tags
}
```

## Naming Convention

- Log Analytics: `log-{customer}-{env}-{region}-{instance}`

## Features

- Centralized log aggregation
- KQL queries
- Workbooks and dashboards
- Alerts and action groups
- 30-730 day retention
- Integration with Azure Monitor
- Diagnostic logs from all Azure resources

## Common Solutions

- **SecurityCenter**: Azure Security Center integration
- **Updates**: Update Management
- **AzureActivity**: Azure Activity Logs
- **ContainerInsights**: Container monitoring
- **VMInsights**: VM monitoring
