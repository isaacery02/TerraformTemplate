# Azure Kubernetes Service (AKS) Module

This module creates an Azure Kubernetes Service cluster with sensible defaults and optional advanced features.

## Overview

Azure Kubernetes Service (AKS) is a managed Kubernetes service that simplifies deploying and managing containerized applications. This module provides a straightforward way to create production-ready AKS clusters.

## Features

- 🚀 Managed Kubernetes cluster
- 🔒 Azure AD integration for RBAC
- 🌐 VNet integration
- 📊 Azure Monitor Container Insights
- 🔐 Managed identity support
- 🔄 Automatic upgrades (optional)
- 📦 Multiple node pools
- 🛡️ Network policies
- 💾 Azure CNI or Kubenet networking

## Module Structure

```
modules/aks/
├── main.tf          # AKS cluster and node pool resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
└── README.md        # This file
```

## Simple Usage Example

### Minimal Configuration (Development)

```hcl
module "aks" {
  source = "../../modules/aks"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  # Network settings
  vnet_subnet_id = module.networking.subnet_ids["aks"]
  
  # Node pool settings
  default_node_pool = {
    name                = "system"
    vm_size            = "Standard_D2s_v3"
    node_count         = 2
    enable_auto_scaling = true
    min_count          = 2
    max_count          = 5
  }

  tags = var.tags
}
```

### Production Configuration

```hcl
module "aks" {
  source = "../../modules/aks"

  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name

  # Kubernetes version
  kubernetes_version = "1.28"

  # Network settings
  vnet_subnet_id      = module.networking.subnet_ids["aks"]
  network_plugin      = "azure"        # Use Azure CNI for production
  network_policy      = "azure"        # Enable network policies
  service_cidr        = "10.1.0.0/16"
  dns_service_ip      = "10.1.0.10"

  # Default node pool (system workloads)
  default_node_pool = {
    name                = "system"
    vm_size            = "Standard_D4s_v3"
    node_count         = 3
    enable_auto_scaling = true
    min_count          = 3
    max_count          = 10
    availability_zones  = ["1", "2", "3"]
  }

  # Additional node pools for workloads
  additional_node_pools = {
    workload = {
      vm_size            = "Standard_D8s_v3"
      node_count         = 2
      enable_auto_scaling = true
      min_count          = 2
      max_count          = 20
      availability_zones  = ["1", "2", "3"]
      node_taints        = ["workload=true:NoSchedule"]
    }
  }

  # Enable monitoring
  enable_log_analytics = true
  log_analytics_workspace_id = module.log_analytics.workspace_id

  # Enable Azure AD integration
  enable_azure_ad_rbac = true
  azure_ad_admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]

  # Automatic upgrades
  automatic_channel_upgrade = "patch"

  tags = var.tags
}
```

## Resource Naming

```
aks-{customer-short-name}-{environment}-{region-code}-{instance}
```

### Examples
- Development: `aks-contoso-dev-eus-001`
- Production: `aks-contoso-prod-eus-001`
- Staging: `aks-contoso-staging-weu-001`

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `customer_short_name` | string | Customer identifier (3-8 chars) |
| `environment` | string | Environment (dev, staging, prod) |
| `location` | string | Azure region |
| `location_code` | string | Short region code |
| `resource_group_name` | string | Resource group name |
| `vnet_subnet_id` | string | Subnet ID for AKS nodes |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `kubernetes_version` | string | Latest stable | Kubernetes version |
| `network_plugin` | string | `"kubenet"` | Network plugin (kubenet/azure) |
| `network_policy` | string | `null` | Network policy (azure/calico) |
| `default_node_pool` | object | See below | Default node pool config |
| `additional_node_pools` | map(object) | `{}` | Additional node pools |
| `enable_log_analytics` | bool | `false` | Enable Container Insights |
| `enable_azure_ad_rbac` | bool | `false` | Enable Azure AD RBAC |
| `automatic_channel_upgrade` | string | `"none"` | Auto upgrade channel |
| `sku_tier` | string | `"Free"` | AKS SKU (Free/Standard) |

## Default Node Pool Configuration

```hcl
default_node_pool = {
  name                = "system"
  vm_size            = "Standard_D2s_v3"
  node_count         = 2
  enable_auto_scaling = true
  min_count          = 2
  max_count          = 5
  availability_zones  = []
  max_pods           = 30
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_id` | AKS cluster ID |
| `cluster_name` | AKS cluster name |
| `kube_config` | Kubernetes configuration (sensitive) |
| `kubelet_identity` | Kubelet managed identity |
| `node_resource_group` | Node resource group name |
| `fqdn` | AKS cluster FQDN |

## Common Scenarios

### 1. Development Cluster (Simple & Cheap)

```hcl
default_node_pool = {
  name       = "system"
  vm_size    = "Standard_B2s"
  node_count = 1
}

network_plugin = "kubenet"  # Simpler, cheaper
sku_tier       = "Free"
```

**Monthly Cost**: ~$50-75

### 2. Production Cluster (Highly Available)

```hcl
default_node_pool = {
  name                = "system"
  vm_size            = "Standard_D4s_v3"
  enable_auto_scaling = true
  min_count          = 3
  max_count          = 10
  availability_zones  = ["1", "2", "3"]
}

network_plugin             = "azure"
network_policy            = "azure"
enable_log_analytics      = true
enable_azure_ad_rbac      = true
automatic_channel_upgrade = "patch"
sku_tier                  = "Standard"  # 99.95% SLA
```

**Monthly Cost**: ~$300-500+ (depending on usage)

### 3. Multi-Tenant with Node Pools

```hcl
default_node_pool = {
  name       = "system"
  vm_size    = "Standard_D2s_v3"
  node_count = 2
}

additional_node_pools = {
  frontend = {
    vm_size    = "Standard_D4s_v3"
    min_count  = 2
    max_count  = 10
    node_labels = {
      "workload" = "frontend"
    }
  }
  
  backend = {
    vm_size    = "Standard_D8s_v3"
    min_count  = 2
    max_count  = 20
    node_labels = {
      "workload" = "backend"
    }
  }
  
  gpu = {
    vm_size    = "Standard_NC6s_v3"
    min_count  = 0
    max_count  = 5
    node_taints = ["gpu=true:NoSchedule"]
  }
}
```

## Network Plugin Comparison

### Kubenet (Simpler)
- ✅ Lower cost (fewer IPs needed)
- ✅ Simpler configuration
- ❌ Limited network integration
- ❌ UDR required for cross-node communication
- 💡 **Best for**: Dev/test, simple apps

### Azure CNI (Advanced)
- ✅ Direct VNet integration
- ✅ Better performance
- ✅ Network policies support
- ❌ Requires more IP addresses
- ❌ More complex configuration
- 💡 **Best for**: Production, enterprise apps

## VM Size Recommendations

### Development
- `Standard_B2s` - 2 vCPU, 4 GB RAM (~$30/month)
- `Standard_D2s_v3` - 2 vCPU, 8 GB RAM (~$70/month)

### Production System Pool
- `Standard_D2s_v3` - 2 vCPU, 8 GB RAM
- `Standard_D4s_v3` - 4 vCPU, 16 GB RAM (~$140/month)

### Production Workload Pool
- `Standard_D8s_v3` - 8 vCPU, 32 GB RAM (~$280/month)
- `Standard_D16s_v3` - 16 vCPU, 64 GB RAM (~$560/month)

### GPU Workloads
- `Standard_NC6s_v3` - 6 vCPU, 112 GB RAM, 1 GPU (~$3,000/month)

## Subnet Planning

### For Kubenet
```hcl
# Small subnet works fine (UDR-based routing)
aks_subnet = {
  address_prefix = "10.0.4.0/24"  # 251 IPs
}
```

### For Azure CNI
```hcl
# Larger subnet required (direct IP assignment)
# Formula: (max_nodes * max_pods_per_node) + buffer

# Example: 100 nodes * 30 pods = 3000 IPs needed
aks_subnet = {
  address_prefix = "10.0.0.0/20"  # 4,091 IPs
}
```

## Security Best Practices

### 1. Enable Azure AD Integration
```hcl
enable_azure_ad_rbac = true
azure_ad_admin_group_object_ids = ["your-admin-group-id"]
```

### 2. Use Private Cluster (Optional)
```hcl
private_cluster_enabled = true
```

### 3. Enable Network Policies
```hcl
network_policy = "azure"
```

### 4. Use Managed Identity
```hcl
identity {
  type = "SystemAssigned"
}
```

### 5. Enable Monitoring
```hcl
enable_log_analytics = true
log_analytics_workspace_id = module.log_analytics.workspace_id
```

### 6. Restrict API Access
```hcl
api_server_authorized_ip_ranges = ["your-office-ip/32"]
```

## Connecting to Your Cluster

### 1. Get Credentials
```bash
# Using Azure CLI
az aks get-credentials \
  --resource-group rg-contoso-prod-eus-001 \
  --name aks-contoso-prod-eus-001

# Using Terraform output
terraform output -raw kube_config > ~/.kube/config
```

### 2. Verify Connection
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

### 3. Deploy Sample App
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get services
```

## Upgrade Strategy

### Automatic Upgrades
```hcl
automatic_channel_upgrade = "patch"   # Auto-apply patch versions
automatic_channel_upgrade = "stable"  # Auto-apply stable releases
automatic_channel_upgrade = "rapid"   # Latest immediately
automatic_channel_upgrade = "none"    # Manual control
```

### Manual Upgrade
```bash
# Check available versions
az aks get-upgrades --resource-group rg-contoso-prod-eus-001 --name aks-contoso-prod-eus-001

# Upgrade cluster
az aks upgrade --resource-group rg-contoso-prod-eus-001 --name aks-contoso-prod-eus-001 --kubernetes-version 1.28.5
```

## Cost Optimization Tips

1. **Use Autoscaling**: Scale down during off-hours
   ```hcl
   enable_auto_scaling = true
   min_count = 2
   max_count = 10
   ```

2. **Use Spot VMs for Dev**: 70-90% discount
   ```hcl
   priority        = "Spot"
   eviction_policy = "Delete"
   spot_max_price  = -1  # Pay up to regular price
   ```

3. **Right-size VMs**: Don't over-provision
   - Start with `Standard_D2s_v3`
   - Monitor CPU/memory usage
   - Adjust based on actual needs

4. **Use Free Tier for Dev**: No control plane charges
   ```hcl
   sku_tier = "Free"
   ```

5. **Enable Cluster Autoscaler**: Scale to zero when possible
   ```hcl
   min_count = 0  # Scale to zero for dev environments
   ```

## Troubleshooting

### Cluster Creation Fails

**Problem**: Insufficient subnet IP addresses
```
Error: not enough IP addresses available in subnet
```

**Solution**: Use larger subnet for Azure CNI
```hcl
# Increase subnet size
aks_subnet = {
  address_prefix = "10.0.0.0/20"  # Instead of /24
}
```

### Node Pool Scaling Issues

**Problem**: Cannot scale past certain number
```
Error: InsufficientSubnetSize
```

**Solution**: Calculate required IPs
```
Required IPs = max_nodes * max_pods_per_node + buffer
```

### Authentication Problems

**Problem**: Cannot connect to cluster
```
Error: Unauthorized
```

**Solution**: Update kubeconfig
```bash
az aks get-credentials --resource-group <rg> --name <cluster> --overwrite-existing
```

### Network Policy Blocks Traffic

**Problem**: Pods cannot communicate
```
Error: Connection timeout
```

**Solution**: Create NetworkPolicy resources
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}
  egress:
  - {}
```

## When to Use AKS

### ✅ Good Use Cases
- Microservices architecture
- Container-based applications
- CI/CD pipelines
- Machine learning workloads
- Multi-tenant applications
- Applications requiring high availability

### ❌ Not Recommended For
- Simple single-container apps → Use **Container Instances**
- Traditional monolithic apps → Use **Virtual Machines**
- Static websites → Use **Static Web Apps**
- Serverless functions → Use **Azure Functions**

## AKS vs. Alternatives

| Feature | AKS | Container Instances | Container Apps | App Service |
|---------|-----|---------------------|----------------|-------------|
| **Complexity** | High | Very Low | Low | Low |
| **Cost (min)** | ~$75/month | ~$10/month | ~$0/month | ~$13/month |
| **Orchestration** | Full K8s | None | Managed | Managed |
| **Scaling** | Full control | Manual | Auto | Auto |
| **Use Case** | Complex apps | Simple tasks | Modern apps | Web apps |
| **Learning Curve** | Steep | Easy | Easy | Easy |

## Dependencies

This module requires:
- Virtual Network with subnet (min /24 for Kubenet, /20+ for Azure CNI)
- (Optional) Log Analytics Workspace for monitoring
- (Optional) Azure AD Group for admin access

## Integration Example

```hcl
# In your deployment's main.tf

module "networking" {
  source = "../../modules/networking"
  # ... networking config
  
  subnets = {
    aks = { 
      address_prefix = "10.0.0.0/20"  # Large for Azure CNI
    }
  }
}

module "log_analytics" {
  source = "../../modules/log-analytics"
  # ... log analytics config
}

module "aks" {
  source = "../../modules/aks"
  
  customer_short_name = var.customer_short_name
  environment         = var.environment
  location            = var.location
  location_code       = var.location_code
  resource_group_name = azurerm_resource_group.main.name
  
  vnet_subnet_id = module.networking.subnet_ids["aks"]
  
  default_node_pool = {
    name                = "system"
    vm_size            = "Standard_D2s_v3"
    enable_auto_scaling = true
    min_count          = 2
    max_count          = 5
  }
  
  enable_log_analytics = true
  log_analytics_workspace_id = module.log_analytics.workspace_id
  
  tags = var.tags
}
```

## Deployment Control

Add to your deployment's `variables.tf`:

```hcl
variable "enable_aks" {
  description = "Enable Azure Kubernetes Service deployment"
  type        = bool
  default     = false
}
```

Add to your deployment's `main.tf`:

```hcl
module "aks" {
  count  = var.enable_aks ? 1 : 0
  source = "../../modules/aks"
  
  # ... configuration
}
```

## Quick Start Checklist

- [ ] Create VNet with appropriate subnet size
- [ ] Decide on network plugin (kubenet vs azure)
- [ ] Choose VM sizes for node pools
- [ ] Configure autoscaling settings
- [ ] Enable Azure AD integration (production)
- [ ] Set up Log Analytics workspace
- [ ] Deploy cluster
- [ ] Get credentials and test connection
- [ ] Deploy sample application
- [ ] Configure kubectl access for team

## Additional Resources

- [AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AKS Best Practices](https://docs.microsoft.com/azure/aks/best-practices)
- [AKS Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Node Pool Best Practices](https://docs.microsoft.com/azure/aks/use-multiple-node-pools)

## Support

For issues or questions:
1. Check AKS cluster diagnostics in Azure Portal
2. Review container logs: `kubectl logs <pod-name>`
3. Check node status: `kubectl describe node <node-name>`
4. Review Azure Activity Log for infrastructure issues

---

**Status**: ✅ README Template  
**Complexity**: ⭐⭐⭐⭐ (High - but we've made it as simple as possible!)  
**Implementation**: Terraform code pending (variables.tf, main.tf, outputs.tf, versions.tf)
