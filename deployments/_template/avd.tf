# Azure Virtual Desktop
# Uncomment and configure to deploy AVD host pools and session hosts.
# Supports large deployments: multiple pools with different VM SKUs per pool.
#
# PREREQUISITES:
#   1. Networking module must be enabled (enable_networking = true)
#   2. Add AVD-specific subnets in var.subnets (see terraform.tfvars.example)
#   3. Set avd_host_pools in terraform.tfvars
#
# TO ENABLE:
#   1. Set enable_avd = true in terraform.tfvars
#   2. Uncomment the module block below
#   3. Uncomment the output blocks in outputs.tf

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
#   # Build the module's host_pools from var.avd_host_pools, resolving subnet_key → subnet_id.
#   # The var.enable_avd guard prevents evaluating module.networking[0] when AVD is disabled.
#   host_pools = var.enable_avd ? {
#     for pool_key, pool in var.avd_host_pools : pool_key => {
#       type                  = pool.type
#       load_balancer_type    = pool.load_balancer_type
#       max_sessions_per_host = pool.max_sessions_per_host
#       app_group_type        = pool.app_group_type
#       start_vm_on_connect   = pool.start_vm_on_connect
#       friendly_name         = pool.friendly_name
#       session_host_count    = pool.session_host_count
#       vm_size               = pool.vm_size
#       vm_name_prefix        = pool.vm_name_prefix
#       subnet_id             = module.networking[0].subnet_ids[pool.subnet_key]
#       os_disk_type          = pool.os_disk_type
#       image_publisher       = pool.image_publisher
#       image_offer           = pool.image_offer
#       image_sku             = pool.image_sku
#       aad_joined            = pool.aad_joined
#       intune_enrollment     = pool.intune_enrollment
#       admin_username        = pool.admin_username
#       admin_password        = pool.admin_password
#       enable_scaling_plan   = pool.enable_scaling_plan
#       license_type          = pool.license_type
#     }
#   } : {}
#
#   scaling_plan_timezone        = var.avd_scaling_plan_timezone
#   scaling_plan_peak_start_time = var.avd_scaling_plan_peak_start_time
#   scaling_plan_peak_end_time   = var.avd_scaling_plan_peak_end_time
#
#   tags = var.tags
# }
