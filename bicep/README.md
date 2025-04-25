# GitHub OIDC with Azure Using Bicep

This solution configures GitHub OpenID Connect (OIDC) authentication with Azure using Bicep templates and Microsoft Graph resource providers.

## Solution Overview

This implementation uses the [Microsoft Graph Bicep Types](https://github.com/microsoftgraph/msgraph-bicep-types) to create and manage Entra ID (Azure AD) resources directly through Bicep, eliminating the need for deployment scripts or manual setup steps.

> **Note:** Microsoft Graph Bicep types are currently in preview and have some important limitations described in the limitations section below.

### Components

- **main.bicep**: The main template that orchestrates the deployment
- **resources.bicep**: Creates Azure resources (managed identities, etc.)
- **entraid.bicep**: Creates Entra ID resources using Microsoft Graph resource providers

### Resources Created

1. **Resource Group**: Container for all Azure resources
2. **App Registration**: The application in Entra ID that GitHub Actions will authenticate as
3. **Service Principal**: Associated with the app registration
4. **Federated Credentials**: For different GitHub workflows scenarios:
   - Main branch
   - Production environment
   - Pull requests
   - Tags/releases
5. **Role Assignments**: Grants necessary permissions to the service principal

## Prerequisites

- Azure subscription
- Azure CLI 2.20.0 or later (for Microsoft Graph Bicep types support)
- Account with permissions to create Entra ID resources and role assignments

## Deployment

### Microsoft Graph Bicep Types

The Microsoft Graph Bicep types are now included with Azure CLI version 2.20.0 and later. You don't need to install anything separately - these resource types will work automatically with your Azure CLI installation.

You can check your Azure CLI version with:

```bash
az --version
```

## Limitations and Considerations

### Not Truly Declarative

Unlike standard ARM resources, Microsoft Graph resources are not truly declarative. **If Graph resource definitions are deleted from the Bicep files, they are not automatically deleted from Entra ID**. This can lead to orphaned resources and requires manual cleanup.

### Deployment Stacks Not Supported

Deployment Stacks (a feature that enables true infrastructure-as-code workflows with state tracking) are not supported with Microsoft Graph Bicep extensions.

### Other Known Limitations

According to the [official Microsoft documentation](https://learn.microsoft.com/en-us/graph/templates/limitations), there are additional limitations:

- Limited resource types available (only specific Graph resources are supported)
- Preview status with potential breaking changes
- Resource deletion not supported through templates
- Limited support for conditional deployments
- No support for copy loops or array properties

For production environments or more complex scenarios, consider using the Terraform implementation instead, which provides more robust state management and true declarative behavior.

If you're using Azure CLI 2.20.0 or later, you're ready to deploy!

### Deploy the Solution

```bash
az deployment sub create \
  --name "github-oidc-deployment" \
  --location eastus \
  --template-file main.bicep \
  --parameters githubOrg=<your-github-org> \
  --parameters githubRepo=<your-github-repo> \
  --parameters resourceGroupName=github-oidc-rg
```

### Configure GitHub Secrets

After deployment, add these secrets to your GitHub repository:

- `AZURE_CLIENT_ID`: The app registration's client ID (from output)
- `AZURE_TENANT_ID`: Your Azure tenant ID (from output)
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID (from output)

## GitHub Workflow Configuration

Use the `.github/workflows/update-infrastructure-graph.yml` workflow for updating your infrastructure. This workflow:

1. Installs the Microsoft Graph Bicep types extension
2. Deploys the Bicep template
3. Outputs the necessary information for GitHub Actions

## Notes

- The Microsoft Graph resource provider requires appropriate permissions to create and manage Entra ID resources.
- If you encounter permission issues, ensure your deployment account has the necessary Azure AD permissions (Application Administrator role).
- The federated identities allow GitHub Actions to authenticate without storing credentials.
- Deployment Stacks [https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks) are not supported by bicep graph
