# Module Index - All Available Modules

Complete reference for all infrastructure modules in this template.

## ✅ Available Modules (25 Total)

### 🏗️ Core Infrastructure (Always Required)

| Module | Purpose | Status | Files |
|--------|---------|--------|-------|
| **networking** | VNet, Subnets, NSGs | ✅ Complete | All .tf + README |
| **storage-account** | Azure Storage | ✅ Complete | All .tf + README |
| **key-vault** | Azure Key Vault | ✅ Complete | All .tf + README |
| **log-analytics** | Centralized Logging | ✅ README | README only |
| **application-insights** | APM & Monitoring | ✅ README | README only |

### 💻 Compute & Hosting

| Module | Purpose | Status | Files |
|--------|---------|--------|-------|
| **virtual-machine** | Azure VMs | ✅ README | README only |
| **app-service** | Web Apps | ✅ README | README only |
| **azure-functions** | Serverless Functions | ✅ README | README only |
| **static-web-app** | Modern Web Apps | ✅ README | README only |
| **aks** | Kubernetes Service | ✅ README | README only |
| **container-instances** | Containerized Apps | ✅ README | README only |
| **container-registry** | Docker/OCI Registry | ✅ README | README only |
| **api-management** | API Gateway & Policies | ✅ README | README only |

### 🌐 Networking & Load Balancing

| Module | Purpose | Status | Files |
|--------|---------|--------|-------|
| **load-balancer** | L4 Load Balancing | ✅ README | README only |
| **application-gateway** | L7 + WAF | ✅ README | README only |
| **vpn-gateway** | VPN Connectivity | ✅ README | README only |
| **azure-firewall** | Network Security | ✅ README | README only |
| **front-door** | Global CDN/LB | ✅ README | README only |
| **public-ip** | Public IP Addresses | ✅ README | README only |
| **azure-bastion** | Secure VM Access | ✅ README | README only |
| **private-endpoints** | Private PaaS Connectivity | ✅ README | README only |

### 💾 Data & Cache

| Module | Purpose | Status | Files |
|--------|---------|--------|-------|
| **sql-database** | Azure SQL | ✅ Complete | All .tf + README |
| **cosmos-db** | NoSQL, Global Distribution | ✅ README | README only |
| **redis-cache** | In-Memory Cache | ✅ README | README only |

### 🔄 Integration & API

| Module | Purpose | Status | Files |
|--------|---------|--------|-------|
| **logic-app** | Workflow Automation | ✅ README | README only |
| **api-management** | API Gateway & Policies | ✅ README | README only |

## 📋 Module Details

### Core Infrastructure Modules

#### networking
**Purpose**: Foundation networking infrastructure  
**Resources**: VNet, Subnets, NSGs  
**Naming**: `vnet-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ Production Ready  
**Files**: main.tf, variables.tf, outputs.tf, versions.tf, README.md

#### storage-account
**Purpose**: Blob and file storage  
**Resources**: Storage Account, Containers  
**Naming**: `st{customer}{env}{region}{instance}`  
**Status**: ✅ Production Ready  
**Files**: main.tf, variables.tf, outputs.tf, versions.tf, README.md

#### key-vault
**Purpose**: Secrets and certificate management  
**Resources**: Key Vault  
**Naming**: `kv-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ Production Ready  
**Files**: main.tf, variables.tf, outputs.tf, versions.tf, README.md

#### log-analytics
**Purpose**: Centralized logging and monitoring  
**Resources**: Log Analytics Workspace  
**Naming**: `log-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### application-insights
**Purpose**: Application Performance Monitoring (APM)  
**Resources**: Application Insights, Workspace connection  
**Naming**: `appi-{apptype}-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

### Compute & Hosting Modules

#### virtual-machine
**Purpose**: IaaS virtual machines  
**Resources**: VM, NIC, Managed Disks  
**Naming**: `vm-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### app-service
**Purpose**: PaaS web application hosting  
**Resources**: App Service, App Service Plan  
**Naming**: `app-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### azure-functions
**Purpose**: Serverless compute  
**Resources**: Function App, App Service Plan, Storage  
**Naming**: `func-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### aks
**Purpose**: Managed Kubernetes cluster for container orchestration  
**Resources**: AKS Cluster, Node Pools  
**Naming**: `aks-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### container-registry
**Purpose**: Private Docker registry  
**Resources**: Container Registry  
**Naming**: `acr{customer}{env}{region}{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### container-instances
**Purpose**: Serverless containerized applications  
**Resources**: Container Group, Containers  
**Naming**: `aci-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### api-management
**Purpose**: API Gateway with policies and security  
**Resources**: APIM Instance, APIs, Products  
**Naming**: `apim-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

### Networking & Load Balancing Modules

#### load-balancer
**Purpose**: Layer 4 load balancing  
**Resources**: Load Balancer, Backend Pools, Health Probes  
**Naming**: `lb-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### application-gateway
**Purpose**: Layer 7 load balancing with WAF  
**Resources**: Application Gateway, Public IP  
**Naming**: `agw-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### front-door
**Purpose**: Global load balancing and CDN  
**Resources**: Front Door Profile, Endpoints  
**Naming**: `fd-{customer}-{env}-global-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### public-ip
**Purpose**: Public IP addresses  
**Resources**: Public IP  
**Naming**: `pip-{purpose}-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### azure-bastion
**Purpose**: Secure RDP/SSH access  
**Resources**: Bastion Host, Public IP  
**Naming**: `bas-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### private-endpoints
**Purpose**: Private connectivity to Azure PaaS services  
**Resources**: Private Endpoints, Private DNS Zones  
**Naming**: `pep-{service}-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

### Data & Cache Modules

#### sql-database
**Purpose**: Relational database service  
**Resources**: SQL Server, SQL Database  
**Naming**: `sql-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ Production Ready  
**Files**: main.tf, variables.tf, outputs.tf, versions.tf, README.md

#### cosmos-db
**Purpose**: Globally distributed multi-model NoSQL database  
**Resources**: Cosmos DB Account, Databases, Containers  
**Naming**: `cosmos-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### redis-cache
**Purpose**: In-memory caching  
**Resources**: Azure Cache for Redis  
**Naming**: `redis-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

### Integration & Automation Modules

#### logic-app
**Purpose**: Workflow automation and integration  
**Resources**: Logic App (Standard/Consumption)  
**Naming**: `logic-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

### Web & Static Content Modules

#### static-web-app
**Purpose**: Modern static web application hosting  
**Resources**: Static Web App  
**Naming**: `stapp-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

### VPN & Connectivity Modules

#### vpn-gateway
**Purpose**: Site-to-site and point-to-site VPN connectivity  
**Resources**: VPN Gateway, Public IP, Local Network Gateway  
**Naming**: `vpngw-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

#### azure-firewall
**Purpose**: Network security and traffic filtering  
**Resources**: Azure Firewall, Firewall Policy, Public IP  
**Naming**: `afw-{customer}-{env}-{region}-{instance}`  
**Status**: ✅ README Template  
**Files**: README.md

## 🎯 Common Module Combinations

### Basic Landing Zone
```
✓ networking
✓ storage-account
✓ key-vault
✓ log-analytics
```

### Web Application Stack
```
✓ networking
✓ storage-account
✓ key-vault
✓ log-analytics
✓ app-service
✓ sql-database
✓ redis-cache
✓ application-gateway
```

### VM-Based Infrastructure
```
✓ networking
✓ storage-account
✓ key-vault
✓ log-analytics
✓ virtual-machine
✓ load-balancer
✓ azure-bastion
```

### Serverless Architecture
```
✓ networking
✓ storage-account
✓ key-vault
✓ log-analytics
✓ azure-functions
✓ sql-database
✓ front-door
```

### Container Workload
```
✓ networking
✓ storage-account
✓ key-vault
✓ log-analytics
✓ container-registry
✓ load-balancer
```

## 📝 Module Implementation Status

| Status | Description | Count |
|--------|-------------|-------|
| ✅ Production Ready | Complete with all .tf files | 4 |
| ✅ README Template | README documentation only | 21 |

**Total Modules**: 25

## 🚀 Next Steps for Module Development

To implement full Terraform code for README-only modules:

1. Copy the pattern from complete modules (networking, storage-account, key-vault, sql-database)
2. Create: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
3. Follow the naming convention
4. Include security best practices
5. Add validation to variables
6. Document outputs

## 🤖 Using Modules with GitHub Copilot

Copilot understands all these modules! Ask:
- "Enable the SQL database module"
- "Add Application Gateway to my deployment"
- "Configure Azure Functions with VNet integration"
- "What modules do I need for a web application?"

## 📚 Documentation

Each module has a detailed README with:
- Usage examples
- Variable descriptions
- Output values
- Naming conventions
- Security features
- Common patterns

See `modules/{module-name}/README.md` for details.
