# Azure Terraform Template - LLM Instructions

## Overview
This is a **reusable Azure infrastructure template** designed for multi-customer, multi-region deployments using Terraform modules. This template follows Azure best practices and uses a standardized naming convention.

## Template Structure

```
TerraformTemplate/
├── modules/                         # Shared, reusable infrastructure modules
│   ├── networking/                 # Virtual Network, Subnets, NSGs ✅
│   ├── storage-account/            # Azure Storage Account ✅
│   ├── key-vault/                  # Azure Key Vault ✅
│   ├── sql-database/               # Azure SQL Server and Database ✅
│   ├── azure-virtual-desktop/      # AVD Host Pools, Session Hosts, Workspace ✅
│   ├── azure-container-apps/       # ACA Environment, Container Apps, ACR ✅
│   ├── cosmos-db/                  # Azure Cosmos DB (NoSQL)
│   ├── virtual-machine/            # Azure Virtual Machines
│   ├── app-service/                # Azure App Service
│   ├── azure-functions/            # Azure Functions
│   ├── static-web-app/             # Azure Static Web Apps
│   ├── logic-app/                  # Azure Logic Apps
│   ├── aks/                        # Azure Kubernetes Service
│   ├── container-registry/         # Azure Container Registry (standalone)
│   ├── container-instances/        # Azure Container Instances
│   ├── api-management/             # Azure API Management (APIM)
│   ├── front-door/                 # Azure Front Door
│   ├── redis-cache/                # Azure Redis Cache
│   ├── load-balancer/              # Azure Load Balancer
│   ├── application-gateway/        # Azure Application Gateway
│   ├── vpn-gateway/                # Azure VPN Gateway
│   ├── azure-firewall/             # Azure Firewall
│   ├── log-analytics/              # Azure Log Analytics Workspace
│   ├── application-insights/       # Azure Application Insights (APM)
│   ├── azure-bastion/              # Azure Bastion
│   ├── public-ip/                  # Azure Public IP Address
│   └── private-endpoints/          # Azure Private Endpoints
├── deployments/                     # Customer/region-specific deployments
│   ├── _template/                  # Template folder to copy for new customers
│   │   ├── avd.tf                  # AVD module call (commented — enable with enable_avd)
│   │   ├── aca.tf                  # ACA module call (commented — enable with enable_aca)
│   │   └── ...
│   ├── customer-region1/           # e.g., contoso-eastus
│   └── customer-region2/           # e.g., contoso-westeurope
└── .github/
    └── copilot-instructions.md     # This file
```

## Azure Naming Convention

All resources follow this pattern:
```
{resource-prefix}-{customer-short-name}-{environment}-{region-code}-{instance}
```

### Examples:
- Virtual Network: `vnet-contoso-prod-eus-001`
- Storage Account: `stcontosoprodeus001` (no hyphens, lowercase only)
- Key Vault: `kv-contoso-prod-eus-001`
- SQL Server: `sql-contoso-prod-eus-001`
- Cosmos DB: `cosmos-contoso-prod-eus-001`
- VM: `vm-contoso-prod-eus-001`
- App Service: `app-contoso-prod-eus-001`
- Functions: `func-contoso-prod-eus-001`
- Static Web App: `stapp-contoso-prod-eus-001`
- Logic App: `logic-contoso-prod-eus-001`
- AKS Cluster: `aks-contoso-prod-eus-001`
- Container Instances: `aci-contoso-prod-eus-001`
- APIM: `apim-contoso-prod-eus-001`
- Application Insights: `appi-web-contoso-prod-eus-001`
- Private Endpoint: `pep-stblob-contoso-prod-eus-001`
- Load Balancer: `lb-contoso-prod-eus-001`
- VPN Gateway: `vpngw-contoso-prod-eus-001`
- Azure Firewall: `afw-contoso-prod-eus-001`
- Front Door: `fd-contoso-prod-global-001`
- Redis Cache: `redis-contoso-prod-eus-001`
- AVD Workspace: `vdws-contoso-prod-eus-001`
- AVD Host Pool: `vdpool-contoso-prod-eus-001-{pool-key}` (e.g., `vdpool-contoso-prod-eus-001-general`)
- AVD App Group: `vdag-contoso-prod-eus-001-{pool-key}`
- AVD Scaling Plan: `vdscaling-contoso-prod-eus-001-{pool-key}`
- AVD Session Host: `{vm_name_prefix}{001..N}` (e.g., `avdgen001`) — max 15 chars (Windows constraint)
- ACA Environment: `cae-contoso-prod-eus-001`
- Container App: `ca-contoso-prod-eus-001-{app-key}` (e.g., `ca-contoso-prod-eus-001-api`)
- Container Registry (ACA): `acrcontosoprodeus001` (no hyphens, lowercase only)

### Region Codes:
- East US: `eus`
- West US: `wus`
- North Europe: `neu`
- West Europe: `weu`
- Southeast Asia: `sea`

## How to Use This Template for New Customers

### 1. Create New Deployment Folder
```bash
cd deployments
mkdir {customer-name}-{region}  # e.g., fabrikam-westus
cd {customer-name}-{region}
```

### 2. Required Files in Each Deployment Folder
Each deployment folder must contain:
- `main.tf` - Calls the required modules from `../../modules/`
- `variables.tf` - Defines all input variables
- `terraform.tfvars` - Contains customer-specific values
- `outputs.tf` - Exports important resource information
- `backend.tf` - Configures remote state storage
- `providers.tf` - Azure provider configuration

### 3. Core Variables (Always Required)
```hcl
customer_short_name          = "contoso"   # 3-8 characters, lowercase
environment                  = "prod"       # prod, dev, staging, uat, test
location                     = "eastus"     # Azure region
location_code                = "eus"        # Short region code
landing_zone_subscription_id = "xxxxx"      # LZ subscription: hub VNet, Log Analytics, Front Door
compute_subscription_id      = "yyyyy"      # Compute subscription: ACA, AVD, databases, storage
```

### 3a. Two-Subscription Architecture
This template deploys across **two Azure subscriptions**:

| Subscription | Variable | What lives here |
|---|---|---|
| Landing Zone | `landing_zone_subscription_id` | Hub VNet, shared Key Vault, Log Analytics, Front Door + WAF |
| Compute | `compute_subscription_id` | Spoke VNet, ACA, AVD, App Service, databases, storage, customer Key Vaults |

Both subscriptions must be in the same **Azure AD tenant**. The Terraform identity (service principal or managed identity) needs `Contributor` on both. Provider aliases in `providers.tf` handle the cross-subscription deployment — no module changes needed.

### 4. Module Control Variables (Boolean Flags)
```hcl
# Landing Zone subscription
enable_hub_networking    = true   # Hub VNet (always recommended)
enable_shared_key_vault  = false  # Shared KV for platform secrets
enable_shared_monitoring = false  # Centralised Log Analytics workspace
enable_front_door        = false  # Global Front Door + WAF

# Compute subscription
enable_spoke_networking   = true   # Spoke VNet (always recommended)
enable_virtual_machine    = false  # Enable as needed
enable_app_service        = false  # Enable as needed
enable_redis_cache        = false  # Enable as needed
enable_avd                = false  # Azure Virtual Desktop
enable_aca                = false  # Azure Container Apps
enable_container_registry = false  # Azure Container Registry (alongside enable_aca)
```

### 5. Networking Variables (Hub + Spoke)
```hcl
# Hub VNet (Landing Zone subscription)
hub_vnet_address_space = ["10.100.0.0/16"]
hub_subnets = {
  GatewaySubnet = { address_prefix = "10.100.0.0/27", name = "GatewaySubnet" }
  management    = { address_prefix = "10.100.1.0/24" }
}

# Spoke VNet (Compute subscription)
spoke_vnet_address_space = ["10.0.0.0/16"]
spoke_subnets = {
  gateway    = { address_prefix = "10.0.0.0/24" }
  appservice = { address_prefix = "10.0.1.0/24" }
  vms        = { address_prefix = "10.0.2.0/24" }
  data       = { address_prefix = "10.0.3.0/24" }
  mgmt       = { address_prefix = "10.0.255.0/24" }
}
```

## Working with Modules

### Module Structure
Each module in `modules/` follows this pattern:
```
module-name/
├── main.tf          # Resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── README.md        # Usage documentation
└── versions.tf      # Provider version constraints
```

### Calling Modules from Deployment
Modules that deploy to the **Compute subscription** receive `providers = { azurerm = azurerm.compute }`.
Modules that deploy to the **Landing Zone subscription** omit `providers` (they use the default provider).

```hcl
# Hub networking — Landing Zone subscription (default provider)
module "hub_networking" {
  count  = var.enable_hub_networking ? 1 : 0
  source = "../../modules/networking"

  vnet_address_space = var.hub_vnet_address_space
  subnets            = var.hub_subnets
  tags               = merge(var.tags, { NetworkTier = "Hub" })
  # ...
}

# Spoke networking — Compute subscription (explicit provider alias)
module "spoke_networking" {
  count  = var.enable_spoke_networking ? 1 : 0
  source = "../../modules/networking"
  providers = { azurerm = azurerm.compute }

  vnet_address_space = var.spoke_vnet_address_space
  subnets            = var.spoke_subnets
  tags               = merge(var.tags, { NetworkTier = "Spoke" })
  # ...
}
```

### Special Subnet Names
The networking module now supports a `name` override for Azure-reserved subnet names:
- `GatewaySubnet` — must be exactly this name for VPN/ER gateway (NSG skipped automatically)
- `AzureFirewallSubnet` — must be exactly this name for Azure Firewall (NSG skipped automatically)
- `AzureBastionSubnet` — must be exactly this name for Azure Bastion

```hcl
hub_subnets = {
  GatewaySubnet = {
    address_prefix = "10.100.0.0/27"
    name           = "GatewaySubnet"  # Override the auto-generated name
  }
}
```

### Adding a New Module
1. Create folder in `modules/`
2. Add `main.tf`, `variables.tf`, `outputs.tf`, `README.md`
3. Follow naming convention in resource names
4. Document all variables in README.md
5. Add boolean control variable to deployment's `variables.tf`
6. Add conditional module call in deployment's `main.tf`

## Multi-Region Deployment Strategy

### Option 1: Separate Deployment Folders (Recommended)
```
deployments/
├── contoso-eastus/
│   ├── main.tf
│   └── terraform.tfvars
└── contoso-westeurope/
    ├── main.tf
    └── terraform.tfvars
```

Each region is deployed independently with separate state files.

### Option 2: Terraform Workspaces
```bash
terraform workspace new contoso-eastus
terraform workspace new contoso-westeurope
terraform workspace select contoso-eastus
```

Both approaches work, but separate folders provide better isolation.

## Common Patterns

### Pattern 1: Basic Landing Zone + Compute
```hcl
enable_hub_networking   = true
enable_spoke_networking = true
# storage_accounts and key_vaults defined in tfvars
```

### Pattern 2: VM-Based Workload
```hcl
enable_hub_networking   = true
enable_spoke_networking = true
enable_virtual_machine  = true
```

### Pattern 3: App Service with Front Door
```hcl
enable_hub_networking    = true
enable_spoke_networking  = true
enable_app_service       = true
enable_front_door        = true   # deploys to LZ subscription
enable_redis_cache       = true
enable_shared_monitoring = true   # centralised logs
```

### Pattern 4: AVD — Small Deployment (single pool)
```hcl
enable_hub_networking   = true
enable_spoke_networking = true
enable_avd              = true

spoke_subnets = {
  mgmt        = { address_prefix = "10.0.255.0/24" }
  avd-general = { address_prefix = "10.0.10.0/23" }
}

avd_host_pools = {
  general = {
    type               = "Pooled"
    load_balancer_type = "BreadthFirst"
    session_host_count = 5
    vm_size            = "Standard_D4s_v5"
    vm_name_prefix     = "avdgen"
    subnet_key         = "avd-general"
    admin_username     = "avdadmin"
    admin_password     = "ChangeMe123!"
  }
}
```

### Pattern 5: AVD — Large Deployment (multi-pool)
```hcl
enable_hub_networking   = true
enable_spoke_networking = true
enable_avd              = true

avd_host_pools = {
  general     = { type = "Pooled",   session_host_count = 30, vm_size = "Standard_D4s_v5",  vm_name_prefix = "avdgen",  subnet_key = "avd-general", load_balancer_type = "BreadthFirst", enable_scaling_plan = true, admin_username = "avdadmin", admin_password = "..." }
  powerusers  = { type = "Pooled",   session_host_count = 10, vm_size = "Standard_D16s_v5", vm_name_prefix = "avdpwr",  subnet_key = "avd-power",   load_balancer_type = "DepthFirst",   admin_username = "avdadmin", admin_password = "..." }
  personal    = { type = "Personal", session_host_count = 5,  vm_size = "Standard_D8s_v5",  vm_name_prefix = "avdprs",  subnet_key = "avd-personal", load_balancer_type = "Persistent",  admin_username = "avdadmin", admin_password = "..." }
}
```

### Pattern 6: Azure Container Apps (public)
```hcl
enable_hub_networking     = true
enable_spoke_networking   = false  # Not required for serverless ACA
enable_aca                = true
enable_container_registry = true

container_apps = {
  frontend = { image = "myacr.azurecr.io/frontend:v1", cpu = 0.5, memory = "1Gi", ingress_external = true }
  api      = { image = "myacr.azurecr.io/api:v1",      cpu = 1.0, memory = "2Gi", ingress_external = false, min_replicas = 2, max_replicas = 20 }
  worker   = { image = "myacr.azurecr.io/worker:v1",   cpu = 2.0, memory = "4Gi", ingress_enabled = false }
}
```

### Pattern 7: Azure Container Apps (private / VNet-integrated)
```hcl
enable_hub_networking          = true
enable_spoke_networking        = true
enable_aca                     = true
enable_container_registry      = true
aca_internal_load_balancer     = true

spoke_subnets = {
  aca = {
    address_prefix = "10.0.20.0/23"   # Must delegate to Microsoft.App/environments
    delegation = { name = "aca-delegation", service = "Microsoft.App/environments" }
  }
}
```

---

## Azure Virtual Desktop — Key Decisions

| Decision | Options | Guidance |
|---|---|---|
| Pool type | `Pooled` / `Personal` | Pooled for shared desktops; Personal for power users needing dedicated VMs |
| Load balancer | `BreadthFirst` / `DepthFirst` | BreadthFirst spreads sessions (recommended); DepthFirst packs sessions to minimise cost |
| Image | Windows 11 AVD / Windows 10 AVD / Server | Use `win11-23h2-avd` multi-session for most deployments |
| Identity | `aad_joined = true` (Entra ID) | Default; works without on-prem AD. Set `false` for hybrid domain join (requires extra extensions) |
| Scaling | `enable_scaling_plan = true` | Recommended for Pooled pools in production — reduces compute cost off-peak |
| VM size | Standard_D4s_v5 – D16s_v5 | D4s_v5 for general (≤12 users), D8s_v5 for medium, D16s_v5 for power users |

**Post-deploy steps for AVD:**
1. Assign users/groups to the Application Groups in Azure Portal
2. Configure FSLogix profile storage (Azure Files recommended)
3. Grant the AVD service principal `Desktop Virtualization Power On Off Contributor` if using scaling plans

---

## Azure Container Apps — Key Decisions

| Decision | Options | Guidance |
|---|---|---|
| Public vs private | `internal_load_balancer_enabled` | Public = no VNet needed; private = set to `true` + add `aca` subnet |
| Registry | `enable_container_registry` | Set `true` to auto-create ACR and wire AcrPull to all apps via managed identity |
| Scaling | `min_replicas`, `max_replicas`, `http_scale_rule_requests` | Set `min_replicas = 0` to scale to zero (saves cost for dev/test) |
| Ingress | `ingress_external = true/false` | External = internet-reachable; false = accessible only within the ACA environment |
| Revision mode | `Single` / `Multiple` | Use `Multiple` for blue/green or canary deployments |

**ACA subnet requirements:**
- Minimum `/27`; Microsoft recommends `/23` for production
- Must be delegated to `Microsoft.App/environments`
- No other resources in that subnet

## When Helping with This Template

### Always:
1. **Check the module exists** before suggesting it
2. **Use the naming convention** for all resource names
3. **Add boolean control variables** for optional modules
4. **Update terraform.tfvars.example** with new variables
5. **Follow Azure best practices** for security and networking
6. **Use managed identity** over keys/secrets where possible
7. **Document new modules** with README.md

### Module Variable Pattern:
```hcl
variable "customer_short_name" {
  description = "Short name for the customer (3-8 chars)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{3,8}$", var.customer_short_name))
    error_message = "Must be 3-8 lowercase letters"
  }
}
```

### Resource Naming Pattern:
```hcl
locals {
  resource_prefix = "${var.resource_type}-${var.customer_short_name}-${var.environment}-${var.location_code}"
  resource_name   = "${local.resource_prefix}-${format("%03d", var.instance_number)}"
}
```

## Deployment Workflow

```bash
# 1. Navigate to deployment folder
cd deployments/customer-region

# 2. Initialize Terraform
terraform init

# 3. Validate configuration
terraform validate

# 4. Review planned changes
terraform plan

# 5. Apply configuration
terraform apply

# 6. View outputs
terraform output
```

## Security Best Practices

1. **Never commit** `terraform.tfvars` with real values
2. **Use Key Vault** for secrets and certificates
3. **Enable managed identity** for Azure resources
4. **Use network security groups** for subnet isolation
5. **Enable diagnostic logging** for all resources
6. **Use private endpoints** where applicable
7. **Store state remotely** in Azure Storage with encryption

## State Management

Remote backend configuration (backend.tf):
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate{customer}001"
    container_name       = "tfstate"
    key                  = "{customer}-{region}.tfstate"
  }
}
```

## Troubleshooting

### Module Not Found
- Verify the relative path: `../../modules/{module-name}`
- Check module folder exists and has required files

### Naming Validation Errors
- Customer name: 3-8 lowercase letters only
- Storage accounts: no hyphens, 3-24 lowercase alphanumeric
- Key Vault: 3-24 alphanumeric + hyphens

### Resource Already Exists
- Check if resource was manually created
- Verify state file is correct
- Consider importing: `terraform import {resource} {id}`

## Adding New Customers - Quick Checklist

- [ ] Create deployment folder: `deployments/{customer}-{region}`
- [ ] Copy template files from example
- [ ] Update `terraform.tfvars` with customer details
- [ ] Set boolean flags for required modules
- [ ] Configure networking (address spaces, subnets)
- [ ] Run `terraform init`
- [ ] Run `terraform validate`
- [ ] Run `terraform plan` and review
- [ ] Run `terraform apply`
- [ ] Document any custom configurations

---

**Remember**: This template is designed for reusability. Keep modules generic and push customer-specific logic to the deployment folder's `terraform.tfvars`.
