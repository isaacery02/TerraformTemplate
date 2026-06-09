# Azure Virtual Desktop
# Uncomment and configure to deploy AVD host pools and session hosts.
# Supports large deployments: multiple pools with different VM SKUs per pool.
#
# PREREQUISITES:
#   1. Networking module must be enabled (enable_networking = true)
#   2. Add AVD-specific subnets in var.subnets (see terraform.tfvars.example)
#   3. Set avd_host_pools in terraform.tfvars
#
# ENABLE: set enable_avd = true in terraform.tfvars

# module "avd" {
#   count  = var.enable_avd ? 1 : 0
#   source = "../../modules/azure-virtual-desktop"
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#
#   workspace_friendly_name = var.avd_workspace_friendly_name
#   workspace_description   = var.avd_workspace_description
#
#   # Resolve subnet keys → full subnet IDs from the networking module.
#   # Each pool's subnet_id is looked up by the subnet_key set in avd_host_pools.
#   host_pools = {
#     for pool_key, pool in var.avd_host_pools : pool_key => merge(pool, {
#       subnet_id = module.networking[0].subnet_ids[pool.subnet_key]
#     })
#   }
#
#   scaling_plan_timezone       = var.avd_scaling_plan_timezone
#   scaling_plan_peak_start_time = var.avd_scaling_plan_peak_start_time
#   scaling_plan_peak_end_time   = var.avd_scaling_plan_peak_end_time
#
#   tags = var.tags
# }
