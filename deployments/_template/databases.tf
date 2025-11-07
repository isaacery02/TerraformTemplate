# Databases
# Multiple SQL Servers and Databases for different applications/microservices
# Each key becomes part of the SQL Server name suffix

# =====================================================
# SQL DATABASES (Multiple Named Instances)
# =====================================================
module "sql_database" {
  for_each = var.sql_databases
  source   = "../../modules/sql-database"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number
  name_suffix         = each.key  # e.g., "orders", "inventory", "appX"
  
  resource_group_name = var.enable_networking ? module.networking[0].resource_group_name : var.existing_resource_group_name
  
  admin_username = each.value.admin_username
  admin_password = each.value.admin_password
  database_name  = each.value.database_name
  sku_name       = each.value.sku_name
  max_size_gb    = each.value.max_size_gb
  zone_redundant = coalesce(each.value.zone_redundant, false)
  
  tags = merge(var.tags, {
    Purpose = each.key  # Tag with the purpose/application name
  })
}

# =====================================================
# COSMOS DB (Optional - Uncomment to use)
# =====================================================
# module "cosmos_db" {
#   for_each = var.cosmos_databases
#   source   = "../../modules/cosmos-db"
#   
#   customer_short_name = var.customer_short_name
#   environment         = var.environment
#   location            = var.location
#   location_code       = var.location_code
#   instance_number     = var.instance_number
#   name_suffix         = each.key
#   
#   resource_group_name = module.networking[0].resource_group_name
#   
#   # Cosmos DB specific configs
#   api_type           = each.value.api_type  # SQL, MongoDB, Cassandra, etc.
#   consistency_level  = each.value.consistency_level
#   
#   tags = merge(var.tags, {
#     Purpose = each.key
#   })
# }
