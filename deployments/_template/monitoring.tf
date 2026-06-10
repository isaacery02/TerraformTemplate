# Monitoring & Observability
#
# Log Analytics Workspace is provisioned in landing-zone.tf (Landing Zone subscription).
# Reference its resource ID as: azurerm_log_analytics_workspace.shared[0].id
# It is available when enable_shared_monitoring = true.
#
# Application Insights below deploys to the Compute subscription and can optionally
# be wired to the shared workspace for centralised APM.

# =====================================================
# APPLICATION INSIGHTS (Compute subscription)
# Connect to the shared Log Analytics workspace for unified APM + logs.
# =====================================================
# module "application_insights" {
#   for_each = var.application_insights_instances
#   source   = "../../modules/application-insights"
#   providers = { azurerm = azurerm.compute }
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   name_suffix         = each.key  # e.g., "web", "api", "worker"
#
#   resource_group_name = var.enable_spoke_networking ? module.spoke_networking[0].resource_group_name : var.existing_compute_resource_group_name
#
#   application_type = each.value.application_type  # web, ios, java, other
#
#   # Connect to the shared Log Analytics workspace in the Landing Zone subscription.
#   # workspace_id = var.enable_shared_monitoring ? azurerm_log_analytics_workspace.shared[0].id : null
#
#   tags = merge(var.tags, { Purpose = each.key })
# }

# =====================================================
# MICROSOFT DEFENDER FOR CLOUD (Both subscriptions)
# Enable per-resource-type pricing via azurerm_security_center_subscription_pricing.
# Uncomment and extend for each resource type you want to protect.
# =====================================================
# resource "azurerm_security_center_subscription_pricing" "defender_vms_lz" {
#   # Default provider — Landing Zone subscription
#   tier          = "Standard"
#   resource_type = "VirtualMachines"
# }
#
# resource "azurerm_security_center_subscription_pricing" "defender_vms_compute" {
#   provider      = azurerm.compute
#   tier          = "Standard"
#   resource_type = "VirtualMachines"
# }
#
# resource "azurerm_security_center_subscription_pricing" "defender_appservices_compute" {
#   provider      = azurerm.compute
#   tier          = "Standard"
#   resource_type = "AppServices"
# }
#
# resource "azurerm_security_center_subscription_pricing" "defender_containers_compute" {
#   provider      = azurerm.compute
#   tier          = "Standard"
#   resource_type = "Containers"
# }
