# Key Vault Module

locals {
  # Key Vault names: 3-24 chars, alphanumeric and hyphens
  # Format: kv-{customer}-{env}-{region}-{instance}-{suffix}
  # Example: kv-contoso-prod-eus-001-secrets or kv-contoso-prod-eus-001-certs
  key_vault_name = var.name_suffix != "" ? "kv-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}-${var.name_suffix}" : "kv-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = local.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  # Security best practices
  enable_rbac_authorization       = var.enable_rbac_authorization
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled

  # Network access control
  network_acls {
    bypass         = "AzureServices"
    default_action = var.network_acls_default_action
    
    ip_rules                   = var.network_acls_ip_rules
    virtual_network_subnet_ids = var.network_acls_subnet_ids
  }

  tags = var.tags
}
