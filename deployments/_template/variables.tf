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

variable "enable_avd" {
  description = "Enable Azure Virtual Desktop module (host pools, session hosts, workspace)"
  type        = bool
  default     = false
}

variable "enable_aca" {
  description = "Enable Azure Container Apps module (environment + container apps)"
  type        = bool
  default     = false
}

variable "enable_container_registry" {
  description = "Create an Azure Container Registry for use with ACA (only relevant when enable_aca = true)"
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
    # Required for delegated subnets (e.g., ACA: service = "Microsoft.App/environments")
    delegation = optional(object({
      name    = string
      service = string
      actions = optional(list(string), [])
    }))
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
# FRONT DOOR + WAF VARIABLES (Optional)
# Used when enable_front_door = true
# =====================================================

variable "front_door_sku_name" {
  description = "Front Door SKU: 'Standard_AzureFrontDoor' or 'Premium_AzureFrontDoor'. WAF managed rules require Premium."
  type        = string
  default     = "Premium_AzureFrontDoor"
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku_name)
    error_message = "front_door_sku_name must be 'Standard_AzureFrontDoor' or 'Premium_AzureFrontDoor'."
  }
}

variable "front_door_response_timeout_seconds" {
  description = "Seconds Front Door waits for an origin response before timing out (16–240)"
  type        = number
  default     = 120
}

variable "front_door_endpoints" {
  description = "Map of Front Door endpoints. Most deployments only need the default entry."
  type = map(object({
    enabled = optional(bool, true)
  }))
  default = { default = {} }
}

variable "front_door_origin_groups" {
  description = <<-EOT
    Map of Front Door origin groups. Each group holds one or more backend origins.
    Key is the group name suffix (e.g., "frontend", "api").
    See modules/front-door/README.md for full examples.
  EOT
  type = map(object({
    session_affinity_enabled             = optional(bool, false)
    health_probe_path                    = optional(string, "/")
    health_probe_protocol                = optional(string, "Https")
    health_probe_interval_seconds        = optional(number, 100)
    load_balancing_sample_size           = optional(number, 4)
    load_balancing_successful_samples_required = optional(number, 3)
    load_balancing_additional_latency_ms = optional(number, 50)
    origins = map(object({
      host_name                      = string
      origin_host_header             = optional(string, null)
      http_port                      = optional(number, 80)
      https_port                     = optional(number, 443)
      priority                       = optional(number, 1)
      weight                         = optional(number, 1000)
      enabled                        = optional(bool, true)
      certificate_name_check_enabled = optional(bool, true)
    }))
  }))
  default = {}
}

variable "front_door_routes" {
  description = <<-EOT
    Map of Front Door routes. Each route connects an endpoint to an origin group.
    Key is the route name suffix (e.g., "frontend", "api").
    See modules/front-door/README.md for full examples.
  EOT
  type = map(object({
    endpoint_key        = string
    origin_group_key    = string
    patterns_to_match   = optional(list(string), ["/*"])
    supported_protocols = optional(list(string), ["Http", "Https"])
    https_redirect      = optional(bool, true)
    forwarding_protocol = optional(string, "HttpsOnly")
    cache_enabled       = optional(bool, false)
    cache_query_string_caching_behavior = optional(string, "IgnoreQueryString")
  }))
  default = {}
}

# ── WAF ────────────────────────────────────────────────────────────────────────

variable "enable_waf" {
  description = "Enable WAF policy on Front Door. Managed rule sets require Premium SKU."
  type        = bool
  default     = true
}

variable "waf_mode" {
  description = "WAF mode: 'Prevention' (blocks) or 'Detection' (logs only). Start with Detection, switch to Prevention after tuning."
  type        = string
  default     = "Prevention"
}

variable "waf_managed_rule_sets" {
  description = "Microsoft-managed WAF rule sets (Premium SKU only). Defaults cover OWASP Top 10 and Bot Manager."
  type = list(object({
    type      = string
    version   = string
    overrides = optional(list(object({
      rule_group_name = string
      rules = optional(list(object({
        rule_id = string
        enabled = bool
        action  = string
      })), [])
    })), [])
  }))
  default = [
    { type = "Microsoft_DefaultRuleSet",    version = "2.1", overrides = [] },
    { type = "Microsoft_BotManagerRuleSet", version = "1.0", overrides = [] }
  ]
}

variable "waf_custom_rules" {
  description = "Custom WAF rules (IP block, geo-filter, rate limit). Applied before managed rule sets. See modules/front-door/README.md for examples."
  type = map(object({
    priority  = number
    rule_type = string
    action    = string
    match_conditions = list(object({
      match_variable     = string
      operator           = string
      match_values       = list(string)
      selector           = optional(string)
      negation_condition = optional(bool, false)
      transforms         = optional(list(string), [])
    }))
    rate_limit_duration_in_minutes = optional(number, 1)
    rate_limit_threshold           = optional(number, 1000)
  }))
  default = {}
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

# =====================================================
# AZURE VIRTUAL DESKTOP VARIABLES (Optional)
# Used when enable_avd = true
# =====================================================

variable "avd_workspace_friendly_name" {
  description = "Display name shown to users in the AVD client (e.g., 'Contoso Virtual Desktop')"
  type        = string
  default     = "Virtual Desktop"
}

variable "avd_workspace_description" {
  description = "Description of the AVD workspace"
  type        = string
  default     = "Azure Virtual Desktop workspace"
}

variable "avd_host_pools" {
  description = <<-EOT
    Map of AVD host pool configurations. Key is used as a name suffix (e.g., "general", "power-users").
    subnet_key references a key in var.subnets — the full subnet ID is resolved in avd.tf.

    Each pool creates: host pool, app group, workspace association, and N session host VMs.

    LARGE DEPLOYMENT EXAMPLE:
      avd_host_pools = {
        general     = { session_host_count = 20, vm_size = "Standard_D4s_v5",  subnet_key = "avd-general", ... }
        power-users = { session_host_count = 5,  vm_size = "Standard_D16s_v5", subnet_key = "avd-power",   ... }
        personal    = { session_host_count = 10, vm_size = "Standard_D8s_v5",  subnet_key = "avd-personal", type = "Personal", load_balancer_type = "Persistent", ... }
      }
  EOT
  type = map(object({
    type                  = string
    load_balancer_type    = string
    max_sessions_per_host = optional(number, 12)
    app_group_type        = optional(string, "Desktop")
    start_vm_on_connect   = optional(bool, true)
    friendly_name         = optional(string, null)
    session_host_count    = number
    vm_size               = string
    vm_name_prefix        = string
    subnet_key            = string
    os_disk_type    = optional(string, "Premium_LRS")
    # source_image_id: set to an Azure Compute Gallery or managed image resource ID to use
    # a golden image. When set, image_publisher/offer/sku are ignored.
    # Example: "/subscriptions/.../galleries/MyGallery/images/AVDGolden/versions/latest"
    source_image_id = optional(string, null)
    image_publisher = optional(string, "MicrosoftWindowsDesktop")
    image_offer     = optional(string, "windows-11")
    image_sku       = optional(string, "win11-23h2-avd")
    aad_joined            = optional(bool, true)
    intune_enrollment     = optional(bool, false)
    admin_username        = string
    admin_password        = string
    enable_scaling_plan   = optional(bool, false)
    # "Windows_Client" enables Azure Hybrid Benefit (~40% savings) for Win10/11 Enterprise images.
    # Set to null for standard pricing. Use "Windows_Server" for Server SKU images.
    license_type          = optional(string, "Windows_Client")
  }))
  default   = {}
  sensitive = true

  validation {
    condition     = alltrue([for k, v in var.avd_host_pools : contains(["Pooled", "Personal"], v.type)])
    error_message = "avd_host_pools[*].type must be 'Pooled' or 'Personal'."
  }
  validation {
    condition     = alltrue([for k, v in var.avd_host_pools : length(v.vm_name_prefix) <= 12])
    error_message = "avd_host_pools[*].vm_name_prefix must be 12 characters or fewer."
  }
}

variable "avd_scaling_plan_timezone" {
  description = "Timezone for AVD scaling plan schedules (e.g., 'Eastern Standard Time', 'UTC')"
  type        = string
  default     = "UTC"
}

variable "avd_scaling_plan_peak_start_time" {
  description = "Time when AVD peak hours begin (HH:MM 24-hour)"
  type        = string
  default     = "09:00"
}

variable "avd_scaling_plan_peak_end_time" {
  description = "Time when AVD peak hours end / ramp-down begins (HH:MM 24-hour)"
  type        = string
  default     = "18:00"
}

# =====================================================
# AZURE CONTAINER APPS VARIABLES (Optional)
# Used when enable_aca = true
# =====================================================

variable "aca_internal_load_balancer" {
  description = "Deploy the Container App Environment with an internal (private) load balancer. Requires an 'aca' subnet in var.subnets."
  type        = bool
  default     = false
}

variable "aca_log_retention_days" {
  description = "Log Analytics retention in days for the ACA environment (30–730)"
  type        = number
  default     = 30
}

variable "acr_sku" {
  description = "Azure Container Registry SKU: 'Basic', 'Standard', or 'Premium'"
  type        = string
  default     = "Standard"
}

variable "container_apps" {
  description = <<-EOT
    Map of container apps to deploy in the ACA environment.
    Key is used as a name suffix (e.g., "api", "worker", "frontend").

    EXAMPLE:
      container_apps = {
        frontend = { image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest", cpu = 0.5, memory = "1Gi", ingress_external = true }
        api      = { image = "myacr.azurecr.io/myapi:v1", cpu = 1.0, memory = "2Gi", ingress_external = false, min_replicas = 2, max_replicas = 20 }
        worker   = { image = "myacr.azurecr.io/worker:v1", cpu = 2.0, memory = "4Gi", ingress_enabled = false }
      }
  EOT
  type = map(object({
    image                    = string
    cpu                      = number
    memory                   = string
    min_replicas             = optional(number, 1)
    max_replicas             = optional(number, 10)
    revision_mode            = optional(string, "Single")
    http_scale_rule_requests = optional(number, null)
    env_vars                 = optional(map(string), {})
    # secrets: key = secret name, value = secret value. WARNING: stored in Terraform state.
    # Use Key Vault references instead of plain values in production.
    secrets                  = optional(map(string), {})
    # secret_env_vars: key = env var name, value = a secret name defined in secrets above
    secret_env_vars          = optional(map(string), {})
    ingress_enabled          = optional(bool, true)
    ingress_external         = optional(bool, false)
    ingress_target_port      = optional(number, 80)
    ingress_transport        = optional(string, "auto")
  }))
  default = {}
}
