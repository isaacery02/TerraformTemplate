# Compute Resources
# VMs, App Services, Azure Functions
# Typically have fewer instances but may be complex configs

# =====================================================
# VIRTUAL MACHINES (Optional)
# =====================================================
# Uncomment and configure as needed
# module "virtual_machine" {
#   count  = var.enable_virtual_machine ? 1 : 0
#   source = "../../modules/virtual-machine"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   subnet_id           = module.networking[0].subnet_ids["vms"]
#   
#   vm_size         = var.vm_size
#   admin_username  = var.vm_admin_username
#   
#   tags = var.tags
# }

# =====================================================
# APP SERVICE (Optional)
# =====================================================
# Uncomment and configure as needed
# module "app_service" {
#   count  = var.enable_app_service ? 1 : 0
#   source = "../../modules/app-service"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   
#   sku_name = var.app_service_sku_name
#   
#   tags = var.tags
# }

# =====================================================
# AZURE FUNCTIONS (Optional)
# =====================================================
# Uncomment and configure as needed
# module "azure_functions" {
#   count  = var.enable_azure_functions ? 1 : 0
#   source = "../../modules/azure-functions"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name   = module.networking[0].resource_group_name
#   storage_account_name  = module.storage_account["functions"].storage_account_name
#   
#   tags = var.tags
# }
