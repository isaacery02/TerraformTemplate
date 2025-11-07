# Monitoring & Observability
# Application Insights, Log Analytics

# =====================================================
# LOG ANALYTICS WORKSPACE (Recommended for Production)
# =====================================================
# module "log_analytics" {
#   count  = var.enable_log_analytics ? 1 : 0
#   source = "../../modules/log-analytics"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   
#   tags = var.tags
# }

# =====================================================
# APPLICATION INSIGHTS (Optional)
# =====================================================
# module "application_insights" {
#   for_each = var.application_insights_instances
#   source   = "../../modules/application-insights"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   name_suffix         = each.key  # e.g., "web", "api", "worker"
#   
#   resource_group_name = module.networking[0].resource_group_name
#   
#   application_type = each.value.application_type  # web, ios, java, other
#   
#   # Optional: Connect to Log Analytics
#   # workspace_id = module.log_analytics[0].workspace_id
#   
#   tags = merge(var.tags, {
#     Purpose = each.key
#   })
# }
