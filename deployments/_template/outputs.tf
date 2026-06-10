# Output Values for Deployment

# =====================================================
# SPOKE NETWORKING OUTPUTS (Compute subscription)
# =====================================================
output "vnet_id" {
  description = "Spoke Virtual Network ID"
  value       = var.enable_spoke_networking ? module.spoke_networking[0].vnet_id : null
}

output "vnet_name" {
  description = "Spoke Virtual Network name"
  value       = var.enable_spoke_networking ? module.spoke_networking[0].vnet_name : null
}

output "subnet_ids" {
  description = "Map of spoke subnet keys to their resource IDs"
  value       = var.enable_spoke_networking ? module.spoke_networking[0].subnet_ids : {}
}

output "resource_group_name" {
  description = "Resource group name for spoke networking resources (Compute subscription)"
  value       = var.enable_spoke_networking ? module.spoke_networking[0].resource_group_name : null
}

# =====================================================
# HUB NETWORKING OUTPUTS (Landing Zone subscription)
# =====================================================
output "hub_vnet_id" {
  description = "Hub Virtual Network ID"
  value       = var.enable_hub_networking ? module.hub_networking[0].vnet_id : null
}

output "hub_vnet_name" {
  description = "Hub Virtual Network name"
  value       = var.enable_hub_networking ? module.hub_networking[0].vnet_name : null
}

output "hub_subnet_ids" {
  description = "Map of hub subnet keys to their resource IDs"
  value       = var.enable_hub_networking ? module.hub_networking[0].subnet_ids : {}
}

output "hub_resource_group_name" {
  description = "Resource group name for hub networking resources (Landing Zone subscription)"
  value       = var.enable_hub_networking ? module.hub_networking[0].resource_group_name : null
}

# =====================================================
# SHARED MONITORING OUTPUTS (Landing Zone subscription)
# =====================================================
output "log_analytics_workspace_id" {
  description = "Shared Log Analytics workspace resource ID (pass to AVD/ACA/App Insights modules)"
  value       = var.enable_shared_monitoring ? azurerm_log_analytics_workspace.shared[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Shared Log Analytics workspace name"
  value       = var.enable_shared_monitoring ? azurerm_log_analytics_workspace.shared[0].name : null
}

# =====================================================
# SHARED KEY VAULT OUTPUT (Landing Zone subscription)
# =====================================================
output "shared_key_vault_uri" {
  description = "Shared Key Vault URI (Landing Zone subscription)"
  value       = var.enable_shared_key_vault ? azurerm_key_vault.shared[0].vault_uri : null
}

output "shared_key_vault_id" {
  description = "Shared Key Vault resource ID"
  value       = var.enable_shared_key_vault ? azurerm_key_vault.shared[0].id : null
}

# =====================================================
# STORAGE ACCOUNT OUTPUTS (Compute subscription)
# =====================================================
output "storage_accounts" {
  description = "Map of storage account names and their details"
  value = {
    for key, sa in module.storage_account : key => {
      name          = sa.storage_account_name
      id            = sa.storage_account_id
      blob_endpoint = sa.primary_blob_endpoint
      purpose       = key
    }
  }
}

# =====================================================
# KEY VAULT OUTPUTS (Compute subscription)
# =====================================================
output "key_vaults" {
  description = "Map of Key Vault names and their details"
  value = {
    for key, kv in module.key_vault : key => {
      name    = kv.key_vault_name
      id      = kv.key_vault_id
      uri     = kv.key_vault_uri
      purpose = key
    }
  }
}

# =====================================================
# SQL DATABASE OUTPUTS (Compute subscription)
# =====================================================
output "sql_databases" {
  description = "Map of SQL Server names and their details"
  value = {
    for key, sql in module.sql_database : key => {
      server_name   = sql.sql_server_name
      server_fqdn   = sql.sql_server_fqdn
      database_name = sql.database_name
      database_id   = sql.database_id
      purpose       = key
    }
  }
  sensitive = true
}

# =====================================================
# AVD OUTPUTS — uncomment alongside the module call in avd.tf
# =====================================================
# output "avd_workspace_id" {
#   description = "AVD Workspace resource ID"
#   value       = var.enable_avd ? module.avd[0].workspace_id : null
# }
# output "avd_workspace_name" {
#   description = "AVD Workspace name"
#   value       = var.enable_avd ? module.avd[0].workspace_name : null
# }
# output "avd_host_pool_ids" {
#   description = "Map of AVD host pool keys to their resource IDs"
#   value       = var.enable_avd ? module.avd[0].host_pool_ids : {}
# }
# output "avd_session_host_names" {
#   description = "Map of session host keys to their VM names"
#   value       = var.enable_avd ? module.avd[0].session_host_names : {}
# }
# output "avd_total_session_hosts" {
#   description = "Total number of session host VMs deployed"
#   value       = var.enable_avd ? module.avd[0].total_session_host_count : 0
# }

# =====================================================
# FRONT DOOR OUTPUTS — uncomment alongside the module call in landing-zone.tf
# =====================================================
# output "front_door_hostnames" {
#   description = "Map of endpoint keys to their Front Door hostnames"
#   value       = var.enable_front_door ? module.front_door[0].endpoint_hostnames : {}
# }
# output "front_door_waf_policy_id" {
#   description = "WAF policy resource ID"
#   value       = var.enable_front_door ? module.front_door[0].waf_policy_id : null
# }

# =====================================================
# ACA OUTPUTS — uncomment alongside the module call in aca.tf
# =====================================================
# output "aca_environment_id" {
#   description = "Container App Environment resource ID"
#   value       = var.enable_aca ? module.aca[0].environment_id : null
# }
# output "aca_environment_name" {
#   description = "Container App Environment name"
#   value       = var.enable_aca ? module.aca[0].environment_name : null
# }
# output "aca_container_app_urls" {
#   description = "Map of container app keys to their public FQDNs (ingress-enabled apps only)"
#   value       = var.enable_aca ? module.aca[0].container_app_urls : {}
# }
# output "aca_acr_login_server" {
#   description = "Azure Container Registry login server (null when enable_container_registry = false)"
#   value       = var.enable_aca ? module.aca[0].acr_login_server : null
# }

# =====================================================
# DEPLOYMENT SUMMARY
# =====================================================
output "deployment_info" {
  description = "Summary of deployed resources"
  value = {
    customer    = var.customer_short_name
    environment = var.environment
    location    = var.location
    region_code = var.location_code
    subscriptions = {
      landing_zone = var.landing_zone_subscription_id
      compute      = var.compute_subscription_id
    }
    resource_counts = {
      hub_networking     = var.enable_hub_networking ? 1 : 0
      spoke_networking   = var.enable_spoke_networking ? 1 : 0
      storage_accounts   = length(var.storage_accounts)
      key_vaults         = length(var.key_vaults)
      sql_databases      = length(var.sql_databases)
      virtual_machines   = var.enable_virtual_machine ? 1 : 0
      app_services       = var.enable_app_service ? 1 : 0
      front_doors        = var.enable_front_door ? 1 : 0
      redis_caches       = var.enable_redis_cache ? 1 : 0
      avd_host_pools     = var.enable_avd ? length(var.avd_host_pools) : 0
      aca_container_apps = var.enable_aca ? length(var.container_apps) : 0
    }
  }
}
