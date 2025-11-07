# App Service Module

This module creates an Azure App Service with App Service Plan.

## Resources Created

- App Service Plan
- App Service (Web App)
- Application Insights (optional)

## Usage

```hcl
module "app_service" {
  source = "../../modules/app-service"
  
  customer_short_name = "contoso"
  environment         = "prod"
  location            = "eastus"
  location_code       = "eus"
  
  resource_group_name = module.networking.resource_group_name
  
  sku_name = "P1v2"
  
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18-lts"
  }
  
  tags = var.tags
}
```

## Naming Convention

- App Service Plan: `asp-{customer}-{env}-{region}-{instance}`
- App Service: `app-{customer}-{env}-{region}-{instance}`

## Features

- Windows or Linux
- Multiple SKU tiers (Free, Basic, Standard, Premium)
- VNet integration support
- Application Insights integration
- HTTPS only by default
