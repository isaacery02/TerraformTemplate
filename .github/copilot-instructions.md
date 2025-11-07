# Azure Terraform Template - LLM Instructions

## Overview
This is a **reusable Azure infrastructure template** designed for multi-customer, multi-region deployments using Terraform modules. This template follows Azure best practices and uses a standardized naming convention.

## Template Structure

```
TerraformTemplate/
├── modules/                    # Shared, reusable infrastructure modules
│   ├── networking/            # Virtual Network, Subnets, NSGs ✅
│   ├── storage-account/       # Azure Storage Account ✅
│   ├── key-vault/            # Azure Key Vault ✅
│   ├── sql-database/         # Azure SQL Server and Database ✅
│   ├── cosmos-db/            # Azure Cosmos DB (NoSQL)
│   ├── virtual-machine/      # Azure Virtual Machines
│   ├── app-service/          # Azure App Service
│   ├── azure-functions/      # Azure Functions
│   ├── static-web-app/       # Azure Static Web Apps
│   ├── logic-app/            # Azure Logic Apps
│   ├── aks/                  # Azure Kubernetes Service
│   ├── container-registry/   # Azure Container Registry
│   ├── container-instances/  # Azure Container Instances
│   ├── api-management/       # Azure API Management (APIM)
│   ├── front-door/           # Azure Front Door
│   ├── redis-cache/          # Azure Redis Cache
│   ├── load-balancer/        # Azure Load Balancer
│   ├── application-gateway/  # Azure Application Gateway
│   ├── vpn-gateway/          # Azure VPN Gateway
│   ├── azure-firewall/       # Azure Firewall
│   ├── log-analytics/        # Azure Log Analytics Workspace
│   ├── application-insights/ # Azure Application Insights (APM)
│   ├── azure-bastion/        # Azure Bastion
│   ├── public-ip/            # Azure Public IP Address
│   └── private-endpoints/    # Azure Private Endpoints
├── deployments/               # Customer/region-specific deployments
│   ├── _template/            # Template folder to copy for new customers
│   ├── customer-region1/     # e.g., contoso-eastus
│   └── customer-region2/     # e.g., contoso-westeurope
└── .github/
    └── copilot-instructions.md  # This file
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
customer_short_name = "contoso"    # 3-8 characters, lowercase
environment         = "prod"        # prod, dev, staging
location            = "eastus"      # Azure region
location_code       = "eus"         # Short region code
subscription_id     = "xxxxx"       # Azure subscription ID
```

### 4. Module Control Variables (Boolean Flags)
```hcl
enable_networking      = true   # Always true for new customers
enable_storage_account = true   # Almost always true
enable_key_vault      = true   # Almost always true
enable_virtual_machine = false  # Enable as needed
enable_app_service    = false  # Enable as needed
enable_front_door     = false  # Enable as needed
enable_redis_cache    = false  # Enable as needed
```

### 5. Networking Variables (Core Infrastructure)
```hcl
vnet_address_space = ["10.0.0.0/16"]

subnets = {
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
```hcl
module "networking" {
  source = "../../modules/networking"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
  tags               = var.tags
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

### Pattern 1: Basic Landing Zone
```hcl
enable_networking      = true
enable_storage_account = true
enable_key_vault      = true
```

### Pattern 2: VM-Based Workload
```hcl
enable_networking      = true
enable_storage_account = true
enable_key_vault      = true
enable_virtual_machine = true
```

### Pattern 3: App Service with Front Door
```hcl
enable_networking      = true
enable_storage_account = true
enable_key_vault      = true
enable_app_service    = true
enable_front_door     = true
enable_redis_cache    = true
```

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
