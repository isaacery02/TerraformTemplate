# Containers & Orchestration
# AKS, Container Instances, Container Registry

# =====================================================
# AZURE KUBERNETES SERVICE (Optional)
# =====================================================
# module "aks" {
#   count  = var.enable_aks ? 1 : 0
#   source = "../../modules/aks"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   
#   resource_group_name = module.networking[0].resource_group_name
#   vnet_subnet_id      = module.networking[0].subnet_ids["aks"]
#   
#   tags = var.tags
# }

# =====================================================
# CONTAINER REGISTRY (Optional)
# =====================================================
# module "container_registry" {
#   count  = var.enable_container_registry ? 1 : 0
#   source = "../../modules/container-registry"
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
# CONTAINER INSTANCES (Optional)
# =====================================================
# module "container_instances" {
#   count  = var.enable_container_instances ? 1 : 0
#   source = "../../modules/container-instances"
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
