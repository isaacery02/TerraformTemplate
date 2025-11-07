# Storage Account Module

locals {
  # Storage account names must be lowercase, no hyphens, 3-24 chars
  # Format: st{customer}{env}{region}{instance}{suffix}
  # Example: stcontosoprodeus001data or stcontosoprodeus001logs
  storage_account_name = var.name_suffix != "" ? "st${var.customer_short_name}${var.environment}${var.location_code}${format("%03d", var.instance_number)}${var.name_suffix}" : "st${var.customer_short_name}${var.environment}${var.location_code}${format("%03d", var.instance_number)}"
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  
  # Security best practices
  https_traffic_only_enabled      = var.enable_https_only
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = false
  infrastructure_encryption_enabled = true
  
  # Enable blob versioning for data protection
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }
    
    container_delete_retention_policy {
      days = var.container_delete_retention_days
    }
  }

  tags = var.tags
}

# Optional Blob Containers
resource "azurerm_storage_container" "containers" {
  for_each = toset(var.blob_containers)
  
  name                  = each.value
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
