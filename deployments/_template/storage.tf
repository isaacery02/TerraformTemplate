# Storage Accounts
# Multiple named instances for different purposes/applications
# Each key becomes part of the storage account name suffix

# =====================================================
# STORAGE ACCOUNTS (Multiple Named Instances)
# =====================================================
module "storage_account" {
  for_each = var.storage_accounts
  source   = "../../modules/storage-account"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number
  name_suffix         = each.key  # e.g., "data", "logs", "appX"
  
  resource_group_name = var.enable_networking ? module.networking[0].resource_group_name : var.existing_resource_group_name
  
  account_tier             = each.value.tier
  account_replication_type = each.value.replication_type
  blob_containers          = each.value.blob_containers
  
  tags = merge(var.tags, {
    Purpose = each.key  # Tag with the purpose/application name
  })
}
