# Input Variables for SQL Database Module

variable "customer_short_name" {
  description = "Short name for the customer (3-8 lowercase characters)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{3,8}$", var.customer_short_name))
    error_message = "Customer short name must be 3-8 lowercase letters only."
  }
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  validation {
    condition     = contains(["prod", "dev", "staging", "uat", "test"], var.environment)
    error_message = "Environment must be one of: prod, dev, staging, uat, test."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "location_code" {
  description = "Short code for the Azure region (e.g., eus for East US)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.location_code))
    error_message = "Location code must be 2-4 lowercase letters."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where SQL Server will be created"
  type        = string
}

variable "instance_number" {
  description = "Instance number for resource naming (default: 1)"
  type        = number
  default     = 1
}

variable "name_suffix" {
  description = "Optional suffix for resource name (e.g., 'appX', 'orders', 'inventory'). Used to identify purpose/application."
  type        = string
  default     = ""
  validation {
    condition     = var.name_suffix == "" || can(regex("^[a-z0-9-]{1,15}$", var.name_suffix))
    error_message = "Name suffix must be 1-15 lowercase alphanumeric characters or hyphens."
  }
}

variable "sql_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator password for SQL Server (should be from Key Vault)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "Password must be at least 12 characters long."
  }
}

variable "database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the database (e.g., Basic, S0, S1, P1)"
  type        = string
  default     = "S1"
}

variable "max_size_gb" {
  description = "Maximum size of the database in gigabytes"
  type        = number
  default     = 250
}

variable "collation" {
  description = "Database collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "zone_redundant" {
  description = "Enable zone redundancy for the database"
  type        = bool
  default     = false
}

variable "enable_azure_ad_admin" {
  description = "Enable Azure AD administrator for SQL Server"
  type        = bool
  default     = false
}

variable "azure_ad_admin_login" {
  description = "Azure AD admin login name"
  type        = string
  default     = null
}

variable "azure_ad_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
  default     = null
}

variable "azure_ad_only_auth" {
  description = "Enable Azure AD only authentication (no SQL auth)"
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for firewall rules"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}

variable "allow_azure_services" {
  description = "Allow Azure services to access the SQL Server"
  type        = bool
  default     = true
}

variable "enable_advanced_threat_protection" {
  description = "Enable advanced threat protection"
  type        = bool
  default     = true
}

variable "threat_detection_email_admins" {
  description = "Send threat detection alerts to account admins"
  type        = bool
  default     = true
}

variable "threat_detection_emails" {
  description = "List of email addresses for threat detection alerts"
  type        = list(string)
  default     = []
}

variable "threat_detection_retention_days" {
  description = "Number of days to retain threat detection logs"
  type        = number
  default     = 30
}

variable "enable_auditing" {
  description = "Enable SQL Server auditing"
  type        = bool
  default     = false
}

variable "audit_storage_endpoint" {
  description = "Storage endpoint for audit logs"
  type        = string
  default     = null
}

variable "audit_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
