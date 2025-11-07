# Multi-Customer, Multi-Region Azure Infrastructure Deployment
#
# This is the main entry point, but resources are organized into separate files:
#
# - providers.tf          : Provider and Terraform configuration
# - backend.tf            : Remote state configuration
# - variables.tf          : All variable definitions
# - terraform.tfvars      : Variable values (this is what you edit!)
# - outputs.tf            : All outputs
#
# RESOURCE FILES (organized by category):
# - core.tf               : Networking, resource groups (always needed)
# - storage.tf            : Storage accounts (multiple named instances)
# - key-vaults.tf         : Key Vaults (multiple named instances)
# - databases.tf          : SQL databases, Cosmos DB
# - compute.tf            : VMs, App Services, Functions
# - containers.tf         : AKS, Container Instances, ACR
# - networking-advanced.tf: Front Door, Load Balancers, VPN, Firewall
# - monitoring.tf         : Application Insights, Log Analytics
# - integration.tf        : Redis, API Management, Service Bus
#
# WHY THIS STRUCTURE?
# - Large deployments can have 100+ resources across 10+ resource types
# - Splitting by category keeps files manageable (< 100 lines each)
# - Team members can work on different files without conflicts
# - Easier to find and modify specific resource types
# - Git diffs show which category of resources changed
#
# TERRAFORM WORKFLOW:
# 1. Copy this _template folder for your customer
# 2. Edit terraform.tfvars with your configuration
# 3. Run: terraform init
# 4. Run: terraform plan (review changes)
# 5. Run: terraform apply
#
# All module calls are in the respective resource files.
# This file serves as documentation only.
