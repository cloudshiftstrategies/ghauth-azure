# GitHub OIDC Authentication for Azure

This project provides a Terraform configuration for setting up GitHub Actions to authenticate with Azure using OpenID Connect (OIDC). This approach eliminates the need for long-lived credentials by using short-lived tokens for authentication.

## Features

- **GitHub Provider Integration**: Automatic creation of GitHub repository secrets
- **Complete OIDC Setup**: Creates all necessary Azure Resource Manager and Entra ID (AD) resources
- **Flexible Options**: Configurable for different environments and GitHub workflows

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- Terraform installed (version >= 1.0.0)
- Permission to create app registrations in Entra ID

## Quick Start

1. Create your terraform.tfvars file (or use the example as a reference):

   ```bash
   # Create a copy of the example file
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit the variables in `terraform.tfvars` with your specific values:

   ```hcl
   # GitHub Configuration
   github_org   = "myorg"
   github_repo  = "myrepo"
   
   # Azure Configuration
   subscription_id     = "00000000-0000-0000-0000-000000000000"
   resource_group_name = "github-oidc-rg"
   
   # GitHub Secrets (Optional)
   create_github_secrets = true
   github_token         = "ghp_xxxxxxxxxxxxxxxxxxxx"
   ```

3. Initialize and apply Terraform:

   ```bash
   terraform init
   terraform apply
   ```

4. Use in your GitHub workflow:

   ```yaml
   jobs:
     deploy:
       runs-on: ubuntu-latest
       permissions:
         id-token: write
         contents: read
       steps:
       - name: Azure Login
         uses: azure/login@v1
         with:
           client-id: ${{ secrets.AZURE_CLIENT_ID }}
           tenant-id: ${{ secrets.AZURE_TENANT_ID }}
           subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
   ```

## Terraform Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `github_org` | GitHub organization/username | (Required) |
| `github_repo` | GitHub repository name | (Required) |
| `github_branch` | Branch name for federated credential | "main" |
| `github_environments` | List of GitHub environments | [] |
| `subscription_id` | Azure subscription ID | (Required) |
| `resource_group_name` | Resource group name | (Required) |
| `location` | Azure region | "eastus" |
| `role_definition_name` | Role to assign to service principal | "Contributor" |
| `create_github_secrets` | Whether to create GitHub secrets | false |
| `github_token` | GitHub token (if creating secrets) | "" |

## Why Terraform Instead of ARM/Bicep?

Terraform is better suited for this GitHub OIDC integration task because:

1. **Unified Resource Management**: Terraform manages both Azure resources (via Azure Resource Manager) and Entra ID resources with a unified approach, while ARM/Bicep primarily focuses on Azure Resource Manager resources only.

2. **Credential Passthrough**: Terraform uses your current authenticated credentials rather than a managed identity. This is important because when using ARM/Bicep deployment scripts, they run in isolated containers with only the permissions of their assigned managed identity, which typically doesn't have Entra ID permissions.

3. **No Container Isolation**: ARM/Bicep deployment scripts run in containers that can't access your authenticated identity. This creates challenges when trying to create Entra ID resources using your permissions.

4. **Cleaner Resource Cleanup**: `terraform destroy` handles cleaning up both Azure resources and Entra ID resources in one operation, while with ARM/Bicep you'd need separate cleanup processes.

5. **GitHub Provider**: Terraform offers a native GitHub provider that can create repository secrets, eliminating manual steps after deployment.

## File Organization

This project organizes resources by provider type for better maintainability:

1. **main.tf**: Core Terraform configuration and data sources
2. **azuread.tf**: Entra ID (Azure AD) resources like app registrations and federated credentials
3. **azurerm.tf**: Azure Resource Manager resources like resource groups
4. **github.tf**: GitHub repository resources like secrets
5. **variables.tf**: All input variables
6. **outputs.tf**: All output values
