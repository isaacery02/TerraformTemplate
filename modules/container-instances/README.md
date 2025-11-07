# Azure Container Instances Module

This module creates Azure Container Instances for running containerized applications without managing infrastructure.

## Features

- Single or multiple container groups
- Windows or Linux containers
- Public or private IP addresses
- VNet integration for private networking
- Persistent storage with Azure Files
- Environment variables and secrets
- Liveness and readiness probes
- Custom DNS configuration
- Automatic restart policies
- GPU support (optional)
- Managed identity support

## Usage

### Basic Container Instance

```hcl
module "container_instance" {
  source = "../../modules/container-instances"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  # Container Configuration
  os_type = "Linux"
  
  containers = [
    {
      name   = "nginx"
      image  = "nginx:latest"
      cpu    = 1
      memory = 1.5
      
      ports = [
        {
          port     = 80
          protocol = "TCP"
        },
        {
          port     = 443
          protocol = "TCP"
        }
      ]
      
      environment_variables = {
        "NGINX_HOST" = "example.com"
      }
    }
  ]
  
  # Network Configuration
  ip_address_type = "Public"
  dns_name_label  = "myapp-${var.customer_short_name}-${var.environment}"
  
  # Restart Policy
  restart_policy = "Always"
  
  tags = var.tags
}
```

### Container with VNet Integration

```hcl
module "container_instance_private" {
  source = "../../modules/container-instances"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  os_type = "Linux"
  
  containers = [
    {
      name   = "api-app"
      image  = "myregistry.azurecr.io/api:v1.0"
      cpu    = 2
      memory = 4
      
      ports = [
        {
          port     = 8080
          protocol = "TCP"
        }
      ]
    }
  ]
  
  # Private Networking
  ip_address_type = "Private"
  subnet_ids      = [module.networking.aci_subnet_id]
  
  # Container Registry Authentication
  image_registry_credentials = [
    {
      server   = "myregistry.azurecr.io"
      username = var.acr_username
      password = var.acr_password
    }
  ]
  
  restart_policy = "OnFailure"
  
  tags = var.tags
}
```

### Multi-Container Group

```hcl
module "container_group" {
  source = "../../modules/container-instances"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  os_type = "Linux"
  
  containers = [
    {
      name   = "web"
      image  = "nginx:alpine"
      cpu    = 0.5
      memory = 1
      
      ports = [
        {
          port     = 80
          protocol = "TCP"
        }
      ]
      
      volume_mounts = [
        {
          name       = "config"
          mount_path = "/etc/nginx/conf.d"
          read_only  = true
        }
      ]
    },
    {
      name   = "sidecar"
      image  = "fluent/fluentd:latest"
      cpu    = 0.5
      memory = 1
      
      environment_variables = {
        "FLUENTD_CONF" = "fluent.conf"
      }
      
      volume_mounts = [
        {
          name       = "logs"
          mount_path = "/var/log"
          read_only  = false
        }
      ]
    }
  ]
  
  # Shared Volumes
  volumes = [
    {
      name = "config"
      azure_file = {
        share_name           = "nginx-config"
        storage_account_name = module.storage_account.storage_account_name
        storage_account_key  = module.storage_account.primary_access_key
      }
    },
    {
      name = "logs"
      empty_dir = {}
    }
  ]
  
  ip_address_type = "Public"
  dns_name_label  = "multi-container-${var.customer_short_name}"
  
  tags = var.tags
}
```

### Container with Secrets

```hcl
module "container_with_secrets" {
  source = "../../modules/container-instances"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  os_type = "Linux"
  
  containers = [
    {
      name   = "app"
      image  = "myapp:latest"
      cpu    = 1
      memory = 2
      
      environment_variables = {
        "APP_MODE" = "production"
      }
      
      secure_environment_variables = {
        "DATABASE_PASSWORD" = var.db_password
        "API_KEY"          = var.api_key
      }
      
      ports = [
        {
          port     = 3000
          protocol = "TCP"
        }
      ]
    }
  ]
  
  ip_address_type = "Private"
  subnet_ids      = [module.networking.aci_subnet_id]
  
  # Managed Identity
  enable_system_assigned_identity = true
  
  tags = var.tags
}
```

## Variables

### Required Variables

- `customer_short_name` - Short name for the customer (3-8 characters)
- `environment` - Environment name (prod, dev, staging)
- `location` - Azure region
- `location_code` - Short region code (eus, wus, etc.)
- `resource_group_name` - Name of the resource group
- `os_type` - Operating system type (Linux or Windows)
- `containers` - List of container definitions

### Container Definition Structure

Each container requires:
- `name` - Container name
- `image` - Container image (with tag)
- `cpu` - CPU cores (0.5, 1, 2, etc.)
- `memory` - Memory in GB (0.5-14 for Linux, 0.5-16 for Windows)
- `ports` - List of exposed ports (optional)
- `environment_variables` - Map of environment variables (optional)
- `secure_environment_variables` - Map of secret variables (optional)
- `volume_mounts` - List of volume mounts (optional)
- `commands` - List of commands to run (optional)
- `liveness_probe` - Health check configuration (optional)
- `readiness_probe` - Readiness check configuration (optional)

### Optional Variables

- `instance_number` - Instance number for naming (default: 1)
- `ip_address_type` - IP address type (default: "Public")
  - Options: Public, Private, None
- `dns_name_label` - DNS name label for public IP (optional)
- `subnet_ids` - List of subnet IDs for VNet integration (required for Private IP)
- `image_registry_credentials` - Container registry authentication (optional)
- `volumes` - Shared volumes for containers (optional)
- `restart_policy` - Restart policy (default: "Always")
  - Options: Always, OnFailure, Never
- `enable_system_assigned_identity` - Enable managed identity (default: false)
- `user_assigned_identity_ids` - User-assigned identity IDs (optional)
- `dns_config` - Custom DNS configuration (optional)
- `diagnostics_config` - Log Analytics configuration (optional)
- `tags` - Resource tags

## Outputs

- `container_group_id` - Container Group resource ID
- `container_group_name` - Container Group name
- `ip_address` - Container Group IP address
- `fqdn` - Fully qualified domain name (if DNS label configured)
- `principal_id` - Managed identity principal ID

## Resource Naming

Resources created by this module follow the naming convention:

- Container Group: `aci-{customer}-{env}-{region}-{instance}`

## OS and Resource Limits

### Linux Containers
- **CPU**: 0.5 to 4 cores
- **Memory**: 0.5 GB to 14 GB
- **GPU**: Optional (K80, P100, V100)

### Windows Containers
- **CPU**: 1 to 4 cores
- **Memory**: 1 GB to 16 GB
- **GPU**: Not supported

### Resource Combinations
CPU and memory must be valid combinations:
- 1 CPU: 0.5-3.5 GB memory
- 2 CPU: 1-7 GB memory
- 4 CPU: 2-14 GB memory

## Restart Policies

| Policy | Behavior | Use Case |
|--------|----------|----------|
| **Always** | Restart on exit | Long-running services |
| **OnFailure** | Restart only on non-zero exit | Batch jobs |
| **Never** | Never restart | One-time tasks |

## Volume Types

### Azure Files Volume
Persistent storage backed by Azure Files:
```hcl
volume = {
  name = "data"
  azure_file = {
    share_name           = "myshare"
    storage_account_name = "mystorageaccount"
    storage_account_key  = "xxx"
  }
}
```

### Empty Directory Volume
Ephemeral storage within container group:
```hcl
volume = {
  name = "temp"
  empty_dir = {}
}
```

### Git Repo Volume
Clone Git repository on startup:
```hcl
volume = {
  name = "repo"
  git_repo = {
    url       = "https://github.com/org/repo.git"
    directory = "."
    revision  = "main"
  }
}
```

### Secret Volume
Mount secrets as files:
```hcl
volume = {
  name = "secrets"
  secret = {
    "config.json" = base64encode(jsonencode({
      key = "value"
    }))
  }
}
```

## Networking

### Public IP
- Accessible from internet
- Optional DNS name label
- Single public IP per container group
- All container ports exposed via public IP

### Private IP (VNet Integration)
- Requires subnet delegation to `Microsoft.ContainerInstance/containerGroups`
- Private IP from subnet range
- No direct internet access
- Requires NAT or firewall for outbound
- Supports network security groups (NSGs)

### Port Mapping
- All containers in group share same IP
- Ports must be unique across containers
- Supported protocols: TCP, UDP

## Health Probes

### Liveness Probe
Checks if container is running:
```hcl
liveness_probe = {
  http_get = {
    path   = "/health"
    port   = 80
    scheme = "Http"
  }
  initial_delay_seconds = 30
  period_seconds        = 10
  failure_threshold     = 3
  success_threshold     = 1
  timeout_seconds       = 5
}
```

### Readiness Probe
Checks if container is ready to receive traffic:
```hcl
readiness_probe = {
  exec = {
    command = ["cat", "/tmp/ready"]
  }
  initial_delay_seconds = 10
  period_seconds        = 5
}
```

Probe types: `http_get`, `exec`

## Common Use Cases

### Web Application
- Simple web apps without orchestration
- Dev/test environments
- Temporary demos

### Batch Processing
- Data processing jobs
- ETL workloads
- Scheduled tasks with restart_policy = "OnFailure"

### CI/CD Build Agents
- Ephemeral build agents
- Test runners
- Deployment tools

### API Backends
- Microservices
- REST APIs
- Webhooks

### Sidecar Pattern
- Logging agents
- Monitoring exporters
- Service mesh proxies
- Configuration sync

## Security Considerations

### Image Security
- Use images from trusted registries
- Scan images for vulnerabilities
- Use specific image tags (not `latest`)
- Keep base images updated

### Secrets Management
- Use `secure_environment_variables` for secrets
- Store secrets in Azure Key Vault
- Use managed identities instead of passwords
- Never log secret values

### Network Security
- Use private IPs for production workloads
- Implement NSG rules on subnet
- Avoid exposing unnecessary ports
- Use VNet integration for internal services

### Identity and Access
- Enable managed identity for Azure service access
- Use Azure RBAC for container group management
- Implement least-privilege access
- Audit identity usage

### Monitoring
- Enable diagnostic logs
- Send logs to Log Analytics
- Monitor container resource usage
- Set up alerts for failures

## Dependencies

### For Public IP
- No special dependencies

### For Private IP (VNet Integration)
- Virtual network with subnet
- Subnet delegation to `Microsoft.ContainerInstance/containerGroups`
- Subnet must have sufficient IP addresses

### For Azure Files Volume
- Azure Storage Account
- File share created
- Storage account key or SAS token

### For Container Registry
- Azure Container Registry (or other registry)
- Registry credentials (username/password or managed identity)

## Subnet Delegation

For VNet integration, delegate subnet:
```hcl
resource "azurerm_subnet" "aci" {
  name                 = "aci-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.10.0/24"]

  delegation {
    name = "aci-delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
```

## Cost Considerations

**Pricing Factors:**
- CPU cores allocated
- Memory (GB) allocated
- Duration (per second billing)
- Operating system (Windows costs more)

**Cost Optimization:**
- Right-size CPU and memory
- Use restart_policy = "Never" for one-time tasks
- Delete container groups when not needed
- Use Azure Spot Containers (if available)
- Monitor and optimize resource usage

**Example Costs (Linux, US East):**
- 1 vCPU, 1 GB RAM: ~$0.0000125/second (~$32/month continuous)
- 2 vCPU, 4 GB RAM: ~$0.0000500/second (~$130/month continuous)

## Limitations

- No persistent storage without Azure Files
- No load balancing between container groups
- No auto-scaling (use Azure Container Apps instead)
- Maximum 60 containers per group
- Maximum 4 cores per container
- No SSH/RDP access (use exec command)
- Limited to single region
- No rolling updates

## When to Use Container Instances

### ✅ Good For:
- Quick container deployment
- Burst compute scenarios
- Batch jobs and task automation
- Dev/test environments
- Event-driven workloads
- Build agents and CI/CD
- Simple web apps

### ❌ Not Ideal For:
- Long-running production workloads (consider AKS)
- Apps requiring orchestration (consider AKS)
- Apps requiring auto-scaling (consider Container Apps)
- Apps requiring load balancing (consider Container Apps)
- Stateful applications without external storage
- Apps requiring service mesh

## Comparison with Other Services

| Feature | Container Instances | Container Apps | AKS |
|---------|-------------------|----------------|-----|
| **Orchestration** | None | Managed | Full Kubernetes |
| **Auto-scaling** | No | Yes | Yes |
| **Pricing** | Per-second | Per-second | VM-based |
| **Complexity** | Simple | Medium | Complex |
| **Use Case** | Tasks/jobs | Web apps/APIs | Enterprise apps |
| **Networking** | Basic | Advanced | Full control |
| **Management** | Minimal | Low | High |

## Troubleshooting

### Container Won't Start
- Check container logs: `az container logs`
- Verify image exists and is accessible
- Check resource limits (CPU/memory)
- Validate environment variables

### Registry Authentication Fails
- Verify registry credentials
- Check registry firewall rules
- Ensure managed identity has AcrPull role
- Test credentials manually

### Network Connectivity Issues
- Verify subnet delegation for private IP
- Check NSG rules
- Ensure sufficient IPs in subnet
- Validate DNS configuration

### Volume Mount Fails
- Verify storage account exists
- Check file share exists
- Validate storage account key
- Ensure network access to storage account

## Best Practices

✅ **Container Design**
- Use lightweight base images
- Implement health checks
- Log to stdout/stderr
- Handle signals gracefully (SIGTERM)

✅ **Resource Management**
- Right-size CPU and memory
- Set restart policies appropriately
- Use resource limits
- Monitor resource usage

✅ **Security**
- Use private IPs for production
- Implement least-privilege access
- Scan images for vulnerabilities
- Rotate secrets regularly

✅ **Operational**
- Enable diagnostic logging
- Use managed identities
- Tag resources appropriately
- Document container dependencies

✅ **Development**
- Test locally with Docker first
- Use specific image tags
- Implement configuration via environment variables
- Version container images

## Integration with Other Services

### Azure Container Registry
- Use managed identity for authentication
- Enable vulnerability scanning
- Use geo-replication for HA

### Azure Monitor
- Send logs to Log Analytics
- Create alerts for failures
- Monitor resource metrics
- Set up dashboards

### Azure Key Vault
- Retrieve secrets at runtime
- Use managed identity for access
- Rotate secrets regularly

### Azure Files
- Persistent storage for containers
- Share data between containers
- Backup important data

## Notes

- Container Instances are billed per second
- No minimum deployment duration
- Supports both Linux and Windows containers
- Ideal for short-lived workloads
- Consider Azure Container Apps for long-running services
- Consider Azure Kubernetes Service (AKS) for orchestration needs
- Use Azure Container Registry for private images
- Enable diagnostic logs for troubleshooting
- Managed identities simplify access to Azure services
