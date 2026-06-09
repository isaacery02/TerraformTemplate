# Azure Container Apps Module
# Creates one Container App Environment with multiple Container Apps.
# Optionally creates an Azure Container Registry with automatic AcrPull RBAC.

locals {
  rg_name               = "rg-aca-${var.customer_short_name}-${var.environment}-${var.location_code}"
  env_name              = "cae-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  log_workspace_name    = "law-aca-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  # ACR names: lowercase, no hyphens, 5-50 chars
  acr_name              = "acr${var.customer_short_name}${var.environment}${var.location_code}${format("%03d", var.instance_number)}"
}

# =====================================================
# RESOURCE GROUP
# =====================================================

resource "azurerm_resource_group" "aca" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# =====================================================
# LOG ANALYTICS WORKSPACE
# Required by Container App Environment for telemetry.
# =====================================================

resource "azurerm_log_analytics_workspace" "aca" {
  name                = local.log_workspace_name
  location            = azurerm_resource_group.aca.location
  resource_group_name = azurerm_resource_group.aca.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# =====================================================
# CONTAINER APP ENVIRONMENT
# All apps in this module share this environment.
# For network isolation, deploy a separate module instance.
# =====================================================

resource "azurerm_container_app_environment" "env" {
  name                           = local.env_name
  location                       = azurerm_resource_group.aca.location
  resource_group_name            = azurerm_resource_group.aca.name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.aca.id
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  tags                           = var.tags
}

# =====================================================
# CONTAINER REGISTRY (optional)
# =====================================================

resource "azurerm_container_registry" "acr" {
  count = var.enable_container_registry ? 1 : 0

  name                = local.acr_name
  resource_group_name = azurerm_resource_group.aca.name
  location            = azurerm_resource_group.aca.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = var.tags
}

# =====================================================
# CONTAINER APPS
# One per entry in var.container_apps.
# =====================================================

resource "azurerm_container_app" "apps" {
  for_each = var.container_apps

  name                         = "ca-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}-${each.key}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.aca.name
  revision_mode                = each.value.revision_mode
  tags                         = var.tags

  # SystemAssigned identity enables managed auth to ACR (no username/password needed)
  identity {
    type = "SystemAssigned"
  }

  # Wire up ACR only when the registry is enabled in this module
  dynamic "registry" {
    for_each = var.enable_container_registry ? [1] : []
    content {
      server   = azurerm_container_registry.acr[0].login_server
      identity = "system"
    }
  }

  template {
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas

    container {
      name   = each.key
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory

      # Plain-text environment variables
      dynamic "env" {
        for_each = each.value.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      # Secret-backed environment variables (value = secret name)
      dynamic "env" {
        for_each = each.value.secret_env_vars
        content {
          name        = env.key
          secret_name = env.value
        }
      }
    }

    # HTTP-based autoscaling (optional)
    dynamic "http_scale_rule" {
      for_each = each.value.http_scale_rule_requests != null ? [each.value.http_scale_rule_requests] : []
      content {
        name                = "http-scaling"
        concurrent_requests = tostring(http_scale_rule.value)
      }
    }
  }

  # Ingress (external or internal)
  dynamic "ingress" {
    for_each = each.value.ingress_enabled ? [1] : []
    content {
      external_enabled = each.value.ingress_external
      target_port      = each.value.ingress_target_port
      transport        = each.value.ingress_transport

      traffic_weight {
        latest_revision = true
        percentage      = 100
      }
    }
  }

  depends_on = [azurerm_container_registry.acr]
}

# =====================================================
# ACR PULL ROLE ASSIGNMENTS
# Grant each container app's managed identity AcrPull on the registry.
# Only created when enable_container_registry = true.
# =====================================================

resource "azurerm_role_assignment" "acr_pull" {
  for_each = var.enable_container_registry ? var.container_apps : {}

  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.apps[each.key].identity[0].principal_id
}
