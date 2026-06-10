# Core Infrastructure — Compute subscription
# Spoke VNet, subnets, and NSGs for customer workloads.
# Peered back to the hub VNet (Landing Zone) via hub-spoke-peering.tf.

# =====================================================
# SPOKE NETWORKING (Compute subscription)
# =====================================================
module "spoke_networking" {
  count  = var.enable_spoke_networking ? 1 : 0
  source = "../../modules/networking"
  providers = { azurerm = azurerm.compute }

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number

  vnet_address_space = var.spoke_vnet_address_space
  subnets            = var.spoke_subnets

  tags = merge(var.tags, { NetworkTier = "Spoke" })
}
