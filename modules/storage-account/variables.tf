# Input Variables for Storage Account Module

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
  description = "Name of the resource group where storage account will be created"
  type        = string
}

variable "instance_number" {
  description = "Instance number for resource naming (default: 1)"
  type        = number
  default     = 1
  validation {
    condition     = var.instance_number > 0 && var.instance_number < 1000
    error_message = "Instance number must be between 1 and 999."
  }
}

variable "name_suffix" {
  description = "Optional suffix for resource name (e.g., 'data', 'logs', 'appX'). Used to identify purpose/application."
  type        = string
  default     = ""
  validation {
    condition     = var.name_suffix == "" || can(regex("^[a-z0-9]{1,10}$", var.name_suffix))
    error_message = "Name suffix must be 1-10 lowercase alphanumeric characters (no hyphens allowed for storage accounts)."
  }
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Invalid replication type."
  }
}

variable "enable_https_only" {
  description = "Require HTTPS for storage account access"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "TLS version must be TLS1_0, TLS1_1, or TLS1_2."
  }
}

variable "blob_delete_retention_days" {
  description = "Number of days to retain deleted blobs"
  type        = number
  default     = 7
  validation {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365
    error_message = "Retention days must be between 1 and 365."
  }
}

variable "container_delete_retention_days" {
  description = "Number of days to retain deleted containers"
  type        = number
  default     = 7
  validation {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365
    error_message = "Retention days must be between 1 and 365."
  }
}

variable "blob_containers" {
  description = "List of blob container names to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
