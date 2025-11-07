# Advanced Networking
# Front Door, Load Balancers, Application Gateway, VPN, Firewall
# Typically used for production multi-region or high-availability setups

# =====================================================
# FRONT DOOR (Optional - for multi-region)
# =====================================================
# Uncomment and configure as needed
# module "front_door" {
#   count  = var.enable_front_door ? 1 : 0
#   source = "../../modules/front-door"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = "global"
#   location_code       = "global"
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   
#   sku_name = var.front_door_sku_name
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
