# Azure Functions Module

This module creates an Azure Function App with App Service Plan (Consumption or Dedicated).

## Resources Created

- Azure Function App
- App Service Plan (Consumption/Premium/Dedicated)
- Storage Account for function app
- Application Insights (optional)

## Usage

```hcl
module "function_app" {
  source = "../../modules/azure-functions"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name     = module.networking.resource_group_name
  storage_account_name    = module.storage_account.storage_account_name
  storage_account_key     = module.storage_account.primary_access_key
  
  runtime_stack      = "dotnet"  # dotnet, node, python, java
  runtime_version    = "6"
  
  plan_type          = "consumption"  # consumption, premium, dedicated
  
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
    "MyAppSetting"             = "value"
  }
  
  tags = var.tags
}
```

## Naming Convention

- Function App: `func-{customer}-{env}-{region}-{instance}`
- App Service Plan: `asp-func-{customer}-{env}-{region}-{instance}`

## Plan Types

| Type | Use Case | Scaling | Cost |
|------|----------|---------|------|
| Consumption | Event-driven, sporadic | Automatic | Pay-per-execution |
| Premium | VNet integration, no cold start | Automatic | Higher baseline |
| Dedicated | Existing App Service Plan | Manual | Pay for plan |

## Supported Runtimes

- .NET (6, 7, 8)
- Node.js (16, 18, 20)
- Python (3.8, 3.9, 3.10, 3.11)
- Java (8, 11, 17)
- PowerShell (7.2)
