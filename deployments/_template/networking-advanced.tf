# Advanced Networking
# Front Door, Load Balancers, Application Gateway, VPN, Firewall
# Typically used for production multi-region or high-availability setups

# =====================================================
# FRONT DOOR + WAF (Optional)
# Global HTTP/S load balancer with CDN and WAF.
# Does NOT require networking module — Front Door reaches origins over the internet.
#
# TO ENABLE:
#   1. Set enable_front_door = true in terraform.tfvars
#   2. Configure front_door_origin_groups, front_door_routes in terraform.tfvars
#   3. Uncomment the module block below
#   4. Uncomment the output blocks in outputs.tf
# =====================================================

# module "front_door" {
#   count  = var.enable_front_door ? 1 : 0
#   source = "../../modules/front-door"
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

# =====================================================
# LOAD BALANCER (Optional)
# =====================================================
# module "load_balancer" {
#   count  = var.enable_load_balancer ? 1 : 0
#   source = "../../modules/load-balancer"
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
# APPLICATION GATEWAY (Optional)
# =====================================================
# module "application_gateway" {
#   count  = var.enable_application_gateway ? 1 : 0
#   source = "../../modules/application-gateway"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   subnet_id           = module.networking[0].subnet_ids["gateway"]
#   
#   tags = var.tags
# }

# =====================================================
# VPN GATEWAY (Optional)
# =====================================================
# module "vpn_gateway" {
#   count  = var.enable_vpn_gateway ? 1 : 0
#   source = "../../modules/vpn-gateway"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   subnet_id           = module.networking[0].subnet_ids["gateway"]
#   
#   tags = var.tags
# }

# =====================================================
# AZURE FIREWALL (Optional)
# =====================================================
# module "azure_firewall" {
#   count  = var.enable_azure_firewall ? 1 : 0
#   source = "../../modules/azure-firewall"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   subnet_id           = module.networking[0].subnet_ids["gateway"]
#   
#   tags = var.tags
# }
