# Input Variables — Azure Container Apps Module

# =====================================================
# CORE IDENTITY VARIABLES (same pattern across all modules)
# =====================================================

variable "customer_short_name" {
  description = "Short name for the customer (3-8 lowercase characters)"
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
  description = "Azure region where ACA resources will be deployed"
  type        = string
}

variable "location_code" {
  description = "Short code for the Azure region (e.g., 'eus' for East US)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.location_code))
    error_message = "Location code must be 2-4 lowercase letters."
  }
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
  description = "Tags to apply to all ACA resources"
  type        = map(string)
  default     = {}
}

# =====================================================
# CONTAINER APP ENVIRONMENT
# One environment hosts all container apps in this module instance.
# For workload isolation, deploy separate module instances.
# =====================================================

variable "infrastructure_subnet_id" {
  description = <<-EOT
    Subnet ID for VNet integration (Consumption plan with VNet). Leave null for public environment.
    The subnet must be delegated to 'Microsoft.App/environments' and be at least /27.
    Required if internal_load_balancer_enabled = true.
  EOT
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "Deploy the environment with an internal (private) load balancer. Requires infrastructure_subnet_id."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days (30–730)"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730."
  }
}

# =====================================================
# CONTAINER REGISTRY (optional)
# Enable to create an ACR and automatically grant all
# container apps in this module AcrPull access via
# SystemAssigned managed identity.
# =====================================================

variable "enable_container_registry" {
  description = "Create an Azure Container Registry for this environment"
  type        = bool
  default     = false
}

variable "acr_sku" {
  description = "ACR SKU: 'Basic', 'Standard', or 'Premium'. Premium required for geo-replication and private endpoints."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be 'Basic', 'Standard', or 'Premium'."
  }
}

# =====================================================
# CONTAINER APPS
# Each entry deploys one Container App into the shared environment.
# Key becomes part of the resource name (e.g., "api", "worker", "frontend").
# =====================================================

variable "container_apps" {
  description = <<-EOT
    Map of container apps to deploy into the shared Container App Environment.
    Key is used as a name suffix (e.g., "api", "worker", "frontend").

    EXAMPLE — typical three-tier app:
      container_apps = {
        "frontend" = {
          image            = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
          cpu              = 0.5
          memory           = "1Gi"
          ingress_external = true
          ingress_target_port = 80
        }
        "api" = {
          image            = "myacr.azurecr.io/myapi:v1.0"
          cpu              = 1.0
          memory           = "2Gi"
          ingress_external = false
          ingress_target_port = 8080
          min_replicas     = 2
          max_replicas     = 20
        }
        "worker" = {
          image           = "myacr.azurecr.io/myworker:v1.0"
          cpu             = 2.0
          memory          = "4Gi"
          ingress_enabled = false
          min_replicas    = 1
          max_replicas    = 10
        }
      }
  EOT
  type = map(object({
    # ── Image ─────────────────────────────────────────────────────────────
    image = string

    # ── Resources ─────────────────────────────────────────────────────────
    # cpu/memory must be a valid pairing: https://learn.microsoft.com/azure/container-apps/containers
    # Examples: cpu=0.25/memory="0.5Gi", cpu=0.5/memory="1Gi", cpu=1.0/memory="2Gi"
    cpu    = number
    memory = string

    # ── Scaling ───────────────────────────────────────────────────────────
    min_replicas = optional(number, 1)
    max_replicas = optional(number, 10)
    # revision_mode: "Single" (one active revision) or "Multiple" (A/B / canary)
    revision_mode = optional(string, "Single")
    # http_scale_rule_requests: scale out when concurrent HTTP requests exceed this threshold
    http_scale_rule_requests = optional(number, null)

    # ── Environment variables ──────────────────────────────────────────────
    # env_vars: plain-text key/value pairs
    env_vars = optional(map(string), {})
    # secret_env_vars: key = env var name, value = secret name defined in container_app_secrets
    secret_env_vars = optional(map(string), {})

    # ── Ingress ───────────────────────────────────────────────────────────
    ingress_enabled     = optional(bool, true)
    ingress_external    = optional(bool, false)
    ingress_target_port = optional(number, 80)
    # ingress_transport: "auto", "http", "http2", "tcp"
    ingress_transport = optional(string, "auto")
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.container_apps : contains(["Single", "Multiple"], v.revision_mode)])
    error_message = "container_apps[*].revision_mode must be 'Single' or 'Multiple'."
  }
  validation {
    condition     = alltrue([for k, v in var.container_apps : can(regex("^[a-z0-9-]{1,20}$", k))])
    error_message = "container_apps keys must be 1-20 lowercase alphanumeric characters or hyphens."
  }
}
