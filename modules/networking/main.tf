# Networking Module - Virtual Network and Subnets

locals {
  vnet_name = "vnet-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  rg_name   = "rg-network-${var.customer_short_name}-${var.environment}-${var.location_code}"

  # Azure-reserved subnet names that prohibit NSG attachment.
  # GatewaySubnet: VPN/ExpressRoute gateway.
  # AzureFirewallSubnet: Azure Firewall manages its own rules.
  no_nsg_names = toset(["GatewaySubnet", "AzureFirewallSubnet"])

  # Subnets that receive an NSG — filters out Azure-reserved names using the override
  # name (if set) or the map key as a fallback.
  nsg_subnets = {
    for k, v in var.subnets : k => v
    if !contains(local.no_nsg_names, coalesce(v.name, k))
  }
}

# Resource Group
resource "azurerm_resource_group" "network" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  # Use the override name when provided (e.g., "GatewaySubnet"); otherwise generate a standard name.
  name                 = coalesce(each.value.name, "snet-${each.key}-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}")
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service
        actions = delegation.value.actions
      }
    }
  }
}

# Network Security Groups (one per subnet, excluding Azure-reserved subnets)
resource "azurerm_network_security_group" "nsg" {
  for_each = local.nsg_subnets

  name                = "nsg-${each.key}-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSGs with Subnets (only non-reserved subnets)
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = local.nsg_subnets

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
