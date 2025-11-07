# Key Vaults
# Multiple named instances for different purposes/applications
# Each key becomes part of the Key Vault name suffix

# =====================================================
# KEY VAULTS (Multiple Named Instances)
# =====================================================
module "key_vault" {
  for_each = var.key_vaults
  source   = "../../modules/key-vault"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number
  name_suffix         = each.key  # e.g., "secrets", "certs", "appX"
  
  resource_group_name = var.enable_networking ? module.networking[0].resource_group_name : var.existing_resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name                    = each.value.sku_name
  enable_rbac_authorization   = each.value.enable_rbac
  enabled_for_disk_encryption = true
  
  tags = merge(var.tags, {
    Purpose = each.key  # Tag with the purpose/application name
  })
}
