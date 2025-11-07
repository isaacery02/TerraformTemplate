# Core Infrastructure
# This file contains foundational resources that are always required
# - Networking (VNet, Subnets, NSGs)
# - Resource Groups

# =====================================================
# NETWORKING MODULE (Core - Always Required)
# =====================================================
module "networking" {
  count  = var.enable_networking ? 1 : 0
  source = "../../modules/networking"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number
  
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
  
  tags = var.tags
}
