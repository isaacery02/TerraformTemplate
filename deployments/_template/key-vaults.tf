# Key Vaults — Compute subscription
# Customer-application Key Vaults for app secrets, connection strings, and certificates.
# Each key becomes part of the Key Vault name suffix.
#
# For the shared platform Key Vault (AVD creds, service principal secrets),
# see enable_shared_key_vault in landing-zone.tf.

# =====================================================
# KEY VAULTS (Multiple Named Instances)
# =====================================================
module "key_vault" {
  for_each = var.key_vaults
  source   = "../../modules/key-vault"
  providers = { azurerm = azurerm.compute }

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number
  name_suffix         = each.key  # e.g., "secrets", "certs", "appX"

  resource_group_name = var.enable_spoke_networking ? module.spoke_networking[0].resource_group_name : var.existing_compute_resource_group_name
  # tenant_id is the same across both subscriptions (same Azure AD tenant)
  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name                    = each.value.sku_name
  enable_rbac_authorization   = each.value.enable_rbac
  enabled_for_disk_encryption = true

  tags = merge(var.tags, {
    Purpose = each.key
  })
}
