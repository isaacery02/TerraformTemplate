# Input Variables for Networking Module

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
  description = "Short code for the Azure region (e.g., eus for East US, weu for West Europe)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.location_code))
    error_message = "Location code must be 2-4 lowercase letters."
  }
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (e.g., ['10.0.0.0/16'])"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create with their address prefixes"
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string))
  }))
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
