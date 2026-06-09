# Module: azure-virtual-desktop

Deploys a complete Azure Virtual Desktop environment with support for **multiple host pools**, scaling plans, and Entra ID (AAD) join. Designed for large deployments where different user personas require different VM SKUs or session policies.

## What this module creates

| Resource | Count | Naming |
|---|---|---|
| Resource Group | 1 | `rg-avd-{customer}-{env}-{region}` |
| AVD Workspace | 1 | `vdws-{customer}-{env}-{region}-{instance}` |
| Host Pool | 1 per pool entry | `vdpool-{customer}-{env}-{region}-{instance}-{key}` |
| Application Group | 1 per pool entry | `vdag-{customer}-{env}-{region}-{instance}-{key}` |
| Session Host VM | N per pool | `{vm_name_prefix}{001..N}` |
| NIC | 1 per session host | `nic-{vm_name_prefix}{001..N}` |
| Scaling Plan | 0–1 per Pooled pool | `vdscaling-{customer}-{env}-{region}-{instance}-{key}` |

## Quick start

```hcl
module "avd" {
  source = "../../modules/azure-virtual-desktop"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number

  workspace_friendly_name = "Contoso Virtual Desktop"

  host_pools = var.avd_host_pools

  tags = var.tags
}
```

## Minimal `terraform.tfvars` (single pool, 5 hosts)

```hcl
avd_host_pools = {
  general = {
    type               = "Pooled"
    load_balancer_type = "BreadthFirst"
    session_host_count = 5
    vm_size            = "Standard_D4s_v5"
    vm_name_prefix     = "avdgen"          # → avdgen001 … avdgen005
    subnet_id          = "/subscriptions/.../subnets/avd"
    admin_username     = "avdadmin"
    admin_password     = "ChangeMe123!"
  }
}
```

## Large deployment (3 pools, different SKUs)

```hcl
avd_host_pools = {
  # General workforce — balanced CPU/RAM, high density
  general = {
    type                  = "Pooled"
    load_balancer_type    = "BreadthFirst"
    max_sessions_per_host = 12
    session_host_count    = 30
    vm_size               = "Standard_D4s_v5"
    vm_name_prefix        = "avdgen"
    subnet_id             = module.networking[0].subnet_ids["avd-general"]
    image_offer           = "windows-11"
    image_sku             = "win11-23h2-avd"
    admin_username        = "avdadmin"
    admin_password        = var.avd_admin_password
    enable_scaling_plan   = true
  }

  # Power users — high CPU, lower density
  powerusers = {
    type                  = "Pooled"
    load_balancer_type    = "DepthFirst"
    max_sessions_per_host = 4
    session_host_count    = 10
    vm_size               = "Standard_D16s_v5"
    vm_name_prefix        = "avdpwr"
    subnet_id             = module.networking[0].subnet_ids["avd-power"]
    admin_username        = "avdadmin"
    admin_password        = var.avd_admin_password
    enable_scaling_plan   = false
  }

  # Dedicated desktops — 1:1 user-to-VM ratio
  personal = {
    type                  = "Personal"
    load_balancer_type    = "Persistent"
    session_host_count    = 5
    vm_size               = "Standard_D8s_v5"
    vm_name_prefix        = "avdprs"
    subnet_id             = module.networking[0].subnet_ids["avd-personal"]
    admin_username        = "avdadmin"
    admin_password        = var.avd_admin_password
    enable_scaling_plan   = false
  }
}
```

## Networking requirements

For AVD session hosts, add dedicated subnets in the networking module:

```hcl
subnets = {
  "avd-general" = { address_prefix = "10.0.10.0/23" }  # /23 = 512 hosts for up to ~30 VMs
  "avd-power"   = { address_prefix = "10.0.12.0/24" }
  "avd-personal" = { address_prefix = "10.0.13.0/24" }
}
```

Minimum subnet sizes: `/27` (32 addresses) per subnet. For large pools, size generously — at least 2× the VM count.

## Entra ID vs Domain Join

| Scenario | `aad_joined` | Notes |
|---|---|---|
| Modern (cloud-only) | `true` (default) | No domain required; uses Entra ID |
| Hybrid (on-prem AD) | `false` | Requires VPN/ExpressRoute + domain join extension (add manually) |
| Intune managed | `true` + `intune_enrollment = true` | MDM enrolled automatically |

## Post-deploy checklist

- [ ] Assign users/groups to Application Groups (via Azure Portal or RBAC)
- [ ] Configure FSLogix profile storage (Azure Files share recommended)
- [ ] Set Conditional Access policies for AVD
- [ ] Test user connection via [Windows App](https://apps.microsoft.com/store/detail/windows-app/)
- [ ] If using scaling plans, grant AVD service principal `Desktop Virtualization Power On Off Contributor` on the resource group

## Variable reference

See `variables.tf` for full descriptions and validation rules. All variables in `host_pools` are documented inline.
