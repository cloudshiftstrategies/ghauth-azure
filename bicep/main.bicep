@description('The name for the resource group')
param resourceGroupName string = 'ghauth-azure-rg'

@description('The location for the resource group')
param location string = 'eastus'

@description('The GitHub organization that will use the OIDC authentication')
param githubOrg string

@description('The GitHub repository that will use the OIDC authentication')
param githubRepo string

@description('The GitHub branch that will use the OIDC authentication')
param githubBranch string = 'main'

@description('The name of the app registration')
param subscriptionName string

targetScope = 'subscription'

// Create a resource group for all resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy resources within the resource group (managed identity, role assignments)
module resourcesModule 'resources.bicep' = {
  name: 'resourcesDeploy'
  scope: resourceGroup
  params: {
    location: location
  }
}

// Deploy Entra ID resources using Microsoft Graph types
module entraIdModule 'entraid.bicep' = {
  name: 'entraIdDeploy'
  scope: resourceGroup
  params: {
    githubOrg: githubOrg
    githubRepo: githubRepo
    githubBranch: githubBranch
    subscriptionName: subscriptionName
  }
  dependsOn: [
    resourcesModule
  ]
}

// Output values that will be needed by GitHub Actions
output subscriptionId string = subscription().subscriptionId
output tenantId string = tenant().tenantId
output clientId string = entraIdModule.outputs.clientId
