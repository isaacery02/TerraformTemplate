# Input Variables for Deployment

# =====================================================
# CORE VARIABLES (Required for All Deployments)
# =====================================================

variable "customer_short_name" {
  description = "Short name for the customer (3-8 lowercase characters, e.g., 'contoso')"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{3,8}$", var.customer_short_name))
    error_message = "Customer short name must be 3-8 lowercase letters only."
  }
}

variable "environment" {
  description = "Environment name (prod, dev, staging, uat, test)"
  type        = string
  validation {
    condition     = contains(["prod", "dev", "staging", "uat", "test"], var.environment)
    error_message = "Environment must be one of: prod, dev, staging, uat, test."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed (e.g., 'eastus', 'westeurope')"
  type        = string
}

variable "location_code" {
  description = "Short code for the Azure region (e.g., 'eus' for East US, 'weu' for West Europe)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.location_code))
    error_message = "Location code must be 2-4 lowercase letters."
  }
}

variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed"
  type        = string
}

variable "instance_number" {
  description = "Instance number for resource naming (typically 1 for first deployment)"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

# =====================================================
# MODULE CONTROL FLAGS (Boolean)
# =====================================================

variable "enable_networking" {
  description = "Enable networking module (VNet, Subnets, NSGs)"
  type        = bool
  default     = true
}

# =====================================================
# STORAGE ACCOUNTS (Multiple Named Instances)
# =====================================================

variable "storage_accounts" {
  description = "Map of storage accounts to create. Key = suffix/purpose (e.g., 'data', 'logs', 'appX')"
  type = map(object({
    tier              = string           # Standard or Premium
    replication_type  = string           # LRS, GRS, ZRS, GZRS, RAGRS, RAGZRS
    blob_containers   = list(string)     # List of container names to create
  }))
  default = {}
  
  validation {
    condition     = alltrue([for k, v in var.storage_accounts : can(regex("^[a-z0-9]{1,10}$", k))])
    error_message = "Storage account keys (suffixes) must be 1-10 lowercase alphanumeric characters (no hyphens)."
  }
}

# =====================================================
# KEY VAULTS (Multiple Named Instances)
# =====================================================

variable "key_vaults" {
  description = "Map of Key Vaults to create. Key = suffix/purpose (e.g., 'secrets', 'certs', 'appX')"
  type = map(object({
    sku_name    = string  # standard or premium
    enable_rbac = bool    # Use RBAC (recommended)
  }))
  default = {}
  
  validation {
    condition     = alltrue([for k, v in var.key_vaults : can(regex("^[a-z0-9-]{1,12}$", k))])
    error_message = "Key Vault keys (suffixes) must be 1-12 lowercase alphanumeric characters or hyphens."
  }
}

# =====================================================
# SQL DATABASES (Multiple Named Instances)
# =====================================================

variable "sql_databases" {
  description = "Map of SQL Servers and Databases to create. Key = suffix/purpose (e.g., 'orders', 'inventory', 'appX')"
  type = map(object({
    admin_username    = string           # SQL admin username
    admin_password    = string           # SQL admin password (use Key Vault reference)
    database_name     = string           # Name of the database
    sku_name          = string           # Basic, S0, S1, S2, P1, P2, etc.
    max_size_gb       = number           # Maximum database size
    zone_redundant    = optional(bool)   # Enable zone redundancy (default: false)
  }))
  default   = {}
  sensitive = true
  
  validation {
    condition     = alltrue([for k, v in var.sql_databases : can(regex("^[a-z0-9-]{1,15}$", k))])
    error_message = "SQL database keys (suffixes) must be 1-15 lowercase alphanumeric characters or hyphens."
  }
}

variable "enable_virtual_machine" {
  description = "Enable virtual machine module"
  type        = bool
  default     = false
}

variable "enable_app_service" {
  description = "Enable App Service module"
  type        = bool
  default     = false
}

variable "enable_front_door" {
  description = "Enable Front Door module (for multi-region deployments)"
  type        = bool
  default     = false
}

variable "enable_redis_cache" {
  description = "Enable Redis Cache module"
  type        = bool
  default     = false
}

# =====================================================
# NETWORKING VARIABLES
# =====================================================

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (e.g., ['10.0.0.0/16'])"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create with their address prefixes"
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string))
  }))
  default = {
    gateway = {
      address_prefix = "10.0.0.0/24"
    }
    appservice = {
      address_prefix = "10.0.1.0/24"
    }
    vms = {
      address_prefix = "10.0.2.0/24"
    }
    data = {
      address_prefix = "10.0.3.0/24"
    }
    mgmt = {
      address_prefix = "10.0.255.0/24"
    }
  }
}

variable "existing_resource_group_name" {
  description = "Existing resource group name (if not using networking module)"
  type        = string
  default     = ""
}

# =====================================================
# VIRTUAL MACHINE VARIABLES (Optional)
# =====================================================

variable "vm_size" {
  description = "VM size (e.g., Standard_D2s_v3)"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureadmin"
}

# =====================================================
# APP SERVICE VARIABLES (Optional)
# =====================================================

variable "app_service_sku_name" {
  description = "App Service Plan SKU (e.g., P1v2, S1, B1)"
  type        = string
  default     = "P1v2"
}

# =====================================================
# FRONT DOOR VARIABLES (Optional)
# =====================================================

variable "front_door_sku_name" {
  description = "Front Door SKU (Standard_AzureFrontDoor or Premium_AzureFrontDoor)"
  type        = string
  default     = "Standard_AzureFrontDoor"
}

# =====================================================
# REDIS CACHE VARIABLES (Optional)
# =====================================================

variable "redis_capacity" {
  description = "Redis cache capacity"
  type        = number
  default     = 1
}

variable "redis_family" {
  description = "Redis cache family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "Redis cache SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}
