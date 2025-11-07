# Azure SQL Database Module

locals {
  # SQL Server naming: sql-{customer}-{env}-{region}-{instance}-{suffix}
  # Example: sql-contoso-prod-eus-001-orders or sql-contoso-prod-eus-001-inventory
  sql_server_name = var.name_suffix != "" ? "sql-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}-${var.name_suffix}" : "sql-${var.customer_short_name}-${var.environment}-${var.location_code}-${format("%03d", var.instance_number)}"
}

# SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = local.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  
  minimum_tls_version = "1.2"
  
  # Azure AD authentication
  azuread_administrator {
    login_username              = var.enable_azure_ad_admin ? var.azure_ad_admin_login : null
    object_id                   = var.enable_azure_ad_admin ? var.azure_ad_admin_object_id : null
    azuread_authentication_only = var.azure_ad_only_auth
  }
  
  tags = var.tags
}

# SQL Database
resource "azurerm_mssql_database" "database" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = var.collation
  sku_name       = var.sku_name
  max_size_gb    = var.max_size_gb
  zone_redundant = var.zone_redundant
  
  # Threat detection
  threat_detection_policy {
    state                      = var.enable_advanced_threat_protection ? "Enabled" : "Disabled"
    email_account_admins       = var.threat_detection_email_admins ? "Enabled" : "Disabled"
    email_addresses            = var.threat_detection_emails
    retention_days             = var.threat_detection_retention_days
  }
  
  tags = var.tags
}

# Firewall Rules
resource "azurerm_mssql_firewall_rule" "firewall_rules" {
  for_each = { for rule in var.allowed_ip_ranges : rule.name => rule }
  
  name             = each.value.name
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Allow Azure Services
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count = var.allow_azure_services ? 1 : 0
  
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Auditing
resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  count = var.enable_auditing ? 1 : 0
  
  server_id              = azurerm_mssql_server.sql_server.id
  storage_endpoint       = var.audit_storage_endpoint
  retention_in_days      = var.audit_retention_days
  log_monitoring_enabled = true
}
