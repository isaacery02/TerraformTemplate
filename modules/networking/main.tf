# Networking Module - Virtual Network and Subnets

locals {
  vnet_name = "vnet-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  
  # Resource group for all networking resources
  rg_name = "rg-network-${var.customer_short_name}-${var.environment}-${var.location_code}"
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

  name                 = "snet-${each.key}-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  # Enable service endpoints if specified
  dynamic "service_endpoints" {
    for_each = lookup(each.value, "service_endpoints", null) != null ? [1] : []
    content {
      service = each.value.service_endpoints
    }
  }
}

# Network Security Groups (one per subnet)
resource "azurerm_network_security_group" "nsg" {
  for_each = var.subnets

  name                = "nsg-${each.key}-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  # Default deny all inbound rule (best practice - explicit rules should be added per customer)
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

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
