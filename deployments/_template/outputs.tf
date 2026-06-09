# Output Values for Deployment

# Networking Outputs
output "vnet_id" {
  description = "Virtual Network ID"
  value       = var.enable_networking ? module.networking[0].vnet_id : null
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = var.enable_networking ? module.networking[0].vnet_name : null
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = var.enable_networking ? module.networking[0].subnet_ids : {}
}

output "resource_group_name" {
  description = "Resource group name for networking resources"
  value       = var.enable_networking ? module.networking[0].resource_group_name : null
}

# Storage Account Outputs (Multiple Instances)
output "storage_accounts" {
  description = "Map of storage account names and their details"
  value = {
    for key, sa in module.storage_account : key => {
      name              = sa.storage_account_name
      id                = sa.storage_account_id
      blob_endpoint     = sa.primary_blob_endpoint
      purpose           = key
    }
  }
}

# Key Vault Outputs (Multiple Instances)
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

# SQL Database Outputs (Multiple Instances)
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
  sensitive = true  # Contains sensitive server info
}

# AVD Outputs — uncomment these alongside the module call in avd.tf
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

# ACA Outputs — uncomment these alongside the module call in aca.tf
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

# Deployment Info
output "deployment_info" {
  description = "Summary of deployed resources"
  value = {
    customer    = var.customer_short_name
    environment = var.environment
    location    = var.location
    region_code = var.location_code
    resource_counts = {
      storage_accounts  = length(var.storage_accounts)
      key_vaults        = length(var.key_vaults)
      sql_databases     = length(var.sql_databases)
      networking        = var.enable_networking ? 1 : 0
      virtual_machines  = var.enable_virtual_machine ? 1 : 0
      app_services      = var.enable_app_service ? 1 : 0
      front_doors       = var.enable_front_door ? 1 : 0
      redis_caches      = var.enable_redis_cache ? 1 : 0
      avd_host_pools    = var.enable_avd ? length(var.avd_host_pools) : 0
      aca_container_apps = var.enable_aca ? length(var.container_apps) : 0
    }
  }
}
