# Module: azure-container-apps

Deploys an **Azure Container App Environment** with multiple Container Apps, optional Container Registry, and automatic managed identity wiring. All apps in one module instance share an environment; for environment-level isolation, use separate module instances.

## What this module creates

| Resource | Count | Naming |
|---|---|---|
| Resource Group | 1 | `rg-aca-{customer}-{env}-{region}` |
| Log Analytics Workspace | 1 | `law-aca-{customer}-{env}-{region}-{instance}` |
| Container App Environment | 1 | `cae-{customer}-{env}-{region}-{instance}` |
| Container App | 1 per app entry | `ca-{customer}-{env}-{region}-{instance}-{key}` |
| Container Registry (optional) | 0–1 | `acr{customer}{env}{region}{instance}` |
| AcrPull Role Assignment | 1 per app (when ACR enabled) | — |

## Quick start

```hcl
module "aca" {
  source = "../../modules/azure-container-apps"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  instance_number     = var.instance_number

  enable_container_registry = true
  acr_sku                   = "Standard"

  container_apps = var.container_apps

  tags = var.tags
}
```

## Example: public web + internal API + background worker

```hcl
container_apps = {
  frontend = {
    image               = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu                 = 0.5
    memory              = "1Gi"
    min_replicas        = 2
    max_replicas        = 20
    ingress_external    = true
    ingress_target_port = 80
    http_scale_rule_requests = 50
  }

  api = {
    image               = "myacr.azurecr.io/myapi:v2.1"
    cpu                 = 1.0
    memory              = "2Gi"
    min_replicas        = 2
    max_replicas        = 30
    ingress_external    = false       # internal only — called by frontend
    ingress_target_port = 8080
    env_vars = {
      ASPNETCORE_ENVIRONMENT = "Production"
      DB_HOST                = "mydb.database.windows.net"
    }
    secret_env_vars = {
      DB_PASSWORD = "db-password-secret"  # references a Container App secret
    }
    http_scale_rule_requests = 100
  }

  worker = {
    image           = "myacr.azurecr.io/myworker:v1.5"
    cpu             = 2.0
    memory          = "4Gi"
    min_replicas    = 1
    max_replicas    = 10
    ingress_enabled = false           # no HTTP endpoint
    env_vars = {
      QUEUE_NAME = "jobs"
    }
  }
}
```

## VNet integration (private environment)

```hcl
module "aca" {
  # ...
  infrastructure_subnet_id       = module.networking[0].subnet_ids["aca"]
  internal_load_balancer_enabled = true
}
```

Subnet requirements:
- Minimum size: `/27`
- Must be delegated to `Microsoft.App/environments`
- Must **not** have NSG rules blocking the ACA control plane

Add this delegation in the networking module's subnet definition:
```hcl
subnets = {
  aca = {
    address_prefix = "10.0.20.0/23"
    delegations = [{
      name    = "Microsoft.App/environments"
      service = "Microsoft.App/environments"
    }]
  }
}
```

## CPU / Memory valid pairings

| CPU | Memory options |
|-----|----------------|
| 0.25 | 0.5Gi |
| 0.5  | 1Gi |
| 0.75 | 1.5Gi |
| 1.0  | 2Gi |
| 1.25 | 2.5Gi |
| 1.5  | 3Gi |
| 1.75 | 3.5Gi |
| 2.0  | 4Gi |
| 4.0  | 8Gi |

## Accessing outputs

```hcl
# URL for the frontend app
output "frontend_url" {
  value = module.aca.container_app_urls["frontend"]
}

# Push an image to the registry
output "acr_push_command" {
  value = "az acr login --name ${module.aca.acr_login_server} && docker push ${module.aca.acr_login_server}/myapi:v1"
}
```

## Variable reference

See `variables.tf` for full descriptions and validation rules. All variables in `container_apps` are documented inline.
