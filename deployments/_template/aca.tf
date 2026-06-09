# Azure Container Apps
# Uncomment and configure to deploy a Container App Environment with apps.
# One environment per module call; for environment isolation use multiple module calls.
#
# PREREQUISITES:
#   1. Networking module must be enabled for VNet integration (optional but recommended)
#   2. Add an ACA subnet in var.subnets if using internal_load_balancer_enabled = true
#   3. Set container_apps in terraform.tfvars
#
# ENABLE: set enable_aca = true in terraform.tfvars

# module "aca" {
#   count  = var.enable_aca ? 1 : 0
#   source = "../../modules/azure-container-apps"
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#
#   # VNet integration — remove these two lines for a public (serverless) environment
#   infrastructure_subnet_id       = var.enable_networking ? module.networking[0].subnet_ids["aca"] : null
#   internal_load_balancer_enabled = var.aca_internal_load_balancer
#
#   # Container Registry — set to true to create an ACR and auto-wire AcrPull to all apps
#   enable_container_registry = var.enable_container_registry
#   acr_sku                   = var.acr_sku
#
#   log_retention_days = var.aca_log_retention_days
#
#   container_apps = var.container_apps
#
#   tags = var.tags
# }
