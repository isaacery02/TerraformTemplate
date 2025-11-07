# Deployment Template README

This is a **template deployment folder** for customer-specific Azure infrastructure.

## 📁 File Organization (Important for Large Deployments!)

Resources are **split by category** to keep files manageable:

| File | Purpose | You Edit? |
|------|---------|-----------|
| **terraform.tfvars** | Variable values | ✅ **YES - This is what you configure!** |
| **providers.tf** | Azure provider config | ❌ No (usually) |
| **backend.tf** | Remote state config | ⚠️ Maybe (for production) |
| **variables.tf** | Variable definitions | ❌ No |
| **outputs.tf** | Output definitions | ❌ No |
| | |
| **core.tf** | Networking, resource groups | ❌ No |
| **storage.tf** | Storage accounts (multiple) | ❌ No |
| **key-vaults.tf** | Key Vaults (multiple) | ❌ No |
| **databases.tf** | SQL, Cosmos DB | ❌ No |
| **compute.tf** | VMs, App Services, Functions | ⚠️ Uncomment as needed |
| **containers.tf** | AKS, ACR, Container Instances | ⚠️ Uncomment as needed |
| **networking-advanced.tf** | Front Door, VPN, Firewall | ⚠️ Uncomment as needed |
| **monitoring.tf** | App Insights, Log Analytics | ⚠️ Uncomment as needed |
| **integration.tf** | Redis, APIM, Service Bus | ⚠️ Uncomment as needed |

### 🎯 Why Split Files?

**Problem**: With 10+ storage accounts, 10+ Key Vaults, VMs, databases, etc., a single `main.tf` becomes 500+ lines and unmanageable.

**Solution**: Split resources by category. Each file stays focused and < 100 lines.

**Benefits**:
- ✅ Easy navigation - storage config is in `storage.tf`, not line 400 of `main.tf`
- ✅ Parallel work - team members edit different files without conflicts
- ✅ Clear git diffs - see which resource types changed
- ✅ Selective targeting - `terraform plan -target=module.storage_account["data"]`

## Quick Start for New Customer

### 1. Copy This Template
```bash
cd deployments
cp -r _template contoso-eastus
cd contoso-eastus
```

### 2. Update Configuration
Copy and edit the terraform.tfvars file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `customer_short_name` - Your customer's short name (3-8 chars)
- `subscription_id` - Azure subscription ID
- `location` and `location_code` - Azure region
- Module flags (enable_networking, enable_storage_account, etc.)
- Networking configuration (address spaces, subnets)

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Validate Configuration
```bash
terraform validate
```

### 5. Review Plan
```bash
terraform plan
```

### 6. Apply Configuration
```bash
terraform apply
```

## Module Control Flags

Use boolean variables to enable/disable modules:

```hcl
enable_networking      = true   # Core - Always required
enable_storage_account = true   # Core - Almost always required
enable_key_vault       = true   # Core - Almost always required
enable_virtual_machine = false  # Optional
enable_app_service     = false  # Optional
enable_front_door      = false  # Optional - for multi-region
enable_redis_cache     = false  # Optional
```

## Multi-Region Deployment

### Option 1: Separate Folders (Recommended)
```
deployments/
├── contoso-eastus/
│   ├── main.tf
│   └── terraform.tfvars
└── contoso-westeurope/
    ├── main.tf
    └── terraform.tfvars
```

Copy the template for each region and update `location` and `location_code`.

### Option 2: Terraform Workspaces
```bash
terraform workspace new contoso-eastus
terraform workspace new contoso-westeurope
terraform workspace select contoso-eastus
```

## File Structure

- `main.tf` - Module calls and resource definitions
- `variables.tf` - Variable declarations
- `terraform.tfvars` - Variable values (customer-specific)
- `outputs.tf` - Output definitions
- `backend.tf` - Remote state configuration (optional)

## Common Patterns

### Pattern 1: Basic Landing Zone (VNet + Storage + Key Vault)
```hcl
enable_networking      = true
enable_storage_account = true
enable_key_vault       = true
```

### Pattern 2: VM Workload
```hcl
enable_networking      = true
enable_storage_account = true
enable_key_vault       = true
enable_virtual_machine = true
```

### Pattern 3: App Service with Caching
```hcl
enable_networking      = true
enable_storage_account = true
enable_key_vault       = true
enable_app_service     = true
enable_redis_cache     = true
```

## Customizing Subnets

Edit the `subnets` variable in `terraform.tfvars`:

```hcl
subnets = {
  frontend = {
    address_prefix = "10.0.10.0/24"
  }
  backend = {
    address_prefix = "10.0.20.0/24"
  }
  database = {
    address_prefix = "10.0.30.0/24"
  }
}
```

## Remote State Storage

For production, configure remote state storage in `backend.tf`:

1. Create a storage account for state files
2. Update `backend.tf` with your details
3. Uncomment the backend block
4. Run `terraform init -reconfigure`

## Best Practices

1. **Never commit** `terraform.tfvars` with real values to version control
2. **Use remote state** for production deployments
3. **Enable only needed modules** to reduce costs
4. **Follow naming conventions** defined in module READMEs
5. **Tag all resources** appropriately
6. **Review plan** before applying changes
7. **Use workspaces or separate folders** for multi-region deployments

## Getting Help

- See [.github/copilot-instructions.md](../../.github/copilot-instructions.md) for full documentation
- Check individual module READMEs in `modules/` folder
- Use GitHub Copilot for assistance (it has full context of this template)
