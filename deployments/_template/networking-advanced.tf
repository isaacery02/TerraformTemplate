# Advanced Networking
# Front Door is defined in landing-zone.tf (Landing Zone subscription).
# The resources below are optional and use the provider noted in each block.

# =====================================================
# LOAD BALANCER (Compute subscription)
# Internal or public L4 load balancer for VMs in the spoke VNet.
# =====================================================
# module "load_balancer" {
#   count  = var.enable_load_balancer ? 1 : 0
#   source = "../../modules/load-balancer"
#   providers = { azurerm = azurerm.compute }
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#
#   resource_group_name = module.spoke_networking[0].resource_group_name
#
#   tags = var.tags
# }

# =====================================================
# APPLICATION GATEWAY (Compute subscription)
# L7 load balancer / WAF for VNet-internal workloads.
# Front Door is preferred for public-facing SaaS workloads.
# =====================================================
# module "application_gateway" {
#   count  = var.enable_application_gateway ? 1 : 0
#   source = "../../modules/application-gateway"
#   providers = { azurerm = azurerm.compute }
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#
#   resource_group_name = module.spoke_networking[0].resource_group_name
#   subnet_id           = module.spoke_networking[0].subnet_ids["gateway"]
#
#   tags = var.tags
# }

# =====================================================
# VPN GATEWAY (Landing Zone subscription)
# Site-to-site or P2S VPN in the hub VNet.
# Requires GatewaySubnet in var.hub_subnets.
# =====================================================
# module "vpn_gateway" {
#   count  = var.enable_vpn_gateway ? 1 : 0
#   source = "../../modules/vpn-gateway"
#   # No providers = {} — uses default provider (Landing Zone subscription)
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#
#   resource_group_name = module.hub_networking[0].resource_group_name
#   subnet_id           = module.hub_networking[0].subnet_ids["GatewaySubnet"]
#
#   tags = var.tags
# }

# =====================================================
# AZURE FIREWALL (Landing Zone subscription)
# Central egress/inspection point in the hub VNet.
# Requires AzureFirewallSubnet (name = "AzureFirewallSubnet") in var.hub_subnets.
# =====================================================
# module "azure_firewall" {
#   count  = var.enable_azure_firewall ? 1 : 0
#   source = "../../modules/azure-firewall"
#   # No providers = {} — uses default provider (Landing Zone subscription)
#
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#
#   resource_group_name = module.hub_networking[0].resource_group_name
#   subnet_id           = module.hub_networking[0].subnet_ids["AzureFirewallSubnet"]
#
#   tags = var.tags
# }
