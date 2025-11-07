# Integration & Caching
# Redis Cache, API Management, Service Bus

# =====================================================
# REDIS CACHE (Optional)
# =====================================================
# module "redis_cache" {
#   count  = var.enable_redis_cache ? 1 : 0
#   source = "../../modules/redis-cache"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   
#   capacity = var.redis_capacity
#   family   = var.redis_family
#   sku_name = var.redis_sku_name
#   
#   tags = var.tags
# }

# =====================================================
# API MANAGEMENT (Optional)
# =====================================================
# module "api_management" {
#   count  = var.enable_api_management ? 1 : 0
#   source = "../../modules/api-management"
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
# SERVICE BUS (Optional)
# =====================================================
# module "service_bus" {
#   count  = var.enable_service_bus ? 1 : 0
#   source = "../../modules/service-bus"
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
