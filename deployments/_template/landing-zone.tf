# Landing Zone Resources
# All resources here deploy to the LANDING ZONE subscription (default provider, no alias).
#
# Contains:
#   - Hub Virtual Network (hub_networking) — peered to the spoke in the Compute subscription
#   - Shared Resource Group               — hosts shared KV + Log Analytics
#   - Shared Key Vault                    — platform secrets (AVD creds, certs, SP secrets)
#   - Log Analytics Workspace             — centralised logs from both subscriptions
#   - Front Door + WAF                    — global HTTP/S entry point (commented — see below)

# =====================================================
# HUB NETWORKING (Landing Zone subscription)
# Reuses the same networking module as the spoke, but:
#   - Different address space (e.g., 10.100.0.0/16)
#   - GatewaySubnet / AzureFirewallSubnet automatically skip NSG attachment
#   - Peered to the spoke via hub-spoke-peering.tf
# =====================================================
module "hub_networking" {
  count  = var.enable_hub_networking ? 1 : 0
  source = "../../modules/networking"
  # No providers = {} — uses default provider (Landing Zone subscription)

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number

  vnet_address_space = var.hub_vnet_address_space
  subnets            = var.hub_subnets

  tags = merge(var.tags, { NetworkTier = "Hub" })
}

# =====================================================
# SHARED RESOURCE GROUP (Landing Zone subscription)
# Created when either shared Key Vault or Log Analytics is enabled.
# =====================================================
resource "azurerm_resource_group" "shared" {
  count    = var.enable_shared_key_vault || var.enable_shared_monitoring ? 1 : 0
  name     = "rg-shared-${var.customer_short_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.tags
}

# =====================================================
# SHARED KEY VAULT (Landing Zone subscription)
# Stores platform-level secrets only — AVD domain-join credentials,
# shared service principal secrets, wildcard certificates.
# Customer-application secrets belong in customer-specific Key Vaults
# in the Compute subscription (key-vaults.tf).
# =====================================================
resource "azurerm_key_vault" "shared" {
  count               = var.enable_shared_key_vault ? 1 : 0
  name                = "kv-shared-${var.customer_short_name}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared[0].name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7

  tags = merge(var.tags, { Purpose = "shared-platform-secrets" })
}

# =====================================================
# LOG ANALYTICS WORKSPACE (Landing Zone subscription)
# Centralised logs for both LZ and Compute workloads.
# AVD session hosts and ACA environments ship logs here.
#
# To wire up resources in the Compute subscription, pass
# this workspace ID into the relevant module calls:
#   azurerm_log_analytics_workspace.shared[0].id
# =====================================================
resource "azurerm_log_analytics_workspace" "shared" {
  count               = var.enable_shared_monitoring ? 1 : 0
  name                = "log-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared[0].name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = var.tags
}

# =====================================================
# FRONT DOOR + WAF (Landing Zone subscription)
# Global HTTP/S load balancer + CDN that routes to Compute
# workloads (ACA, App Service) over public hostnames.
# Private Link / VNet integration is NOT required for
# public-ingress ACA or App Service backends.
#
# TO ENABLE:
#   1. Set enable_front_door = true in terraform.tfvars
#   2. Configure front_door_origin_groups and front_door_routes
#   3. Uncomment the module block below
#   4. Uncomment the Front Door output blocks in outputs.tf
# =====================================================

# module "front_door" {
#   count  = var.enable_front_door ? 1 : 0
#   source = "../../modules/front-door"
#   # No providers = {} — uses default provider (Landing Zone subscription)
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   instance_number     = var.instance_number
#
#   sku_name                 = var.front_door_sku_name
#   response_timeout_seconds = var.front_door_response_timeout_seconds
#
#   endpoints     = var.front_door_endpoints
#   origin_groups = var.front_door_origin_groups
#   routes        = var.front_door_routes
#
#   enable_waf            = var.enable_waf
#   waf_mode              = var.waf_mode
#   waf_managed_rule_sets = var.waf_managed_rule_sets
#   waf_custom_rules      = var.waf_custom_rules
#
#   tags = var.tags
# }
