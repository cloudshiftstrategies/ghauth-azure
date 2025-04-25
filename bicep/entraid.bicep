// https://learn.microsoft.com/en-us/graph/templates/
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.2.0-preview'

@description('The GitHub organization that will use the OIDC authentication')
param githubOrg string

@description('The GitHub repository that will use the OIDC authentication')
param githubRepo string

@description('The GitHub branch that will use the OIDC authentication')
param githubBranch string = 'main'

@description('The name of the app registration')
param subscriptionName string

var appUniqueName = uniqueString(subscription().id, deployment().name)

// Using Microsoft Graph resource provider to create app registration
// https://learn.microsoft.com/en-us/graph/templates/reference/federatedidentitycredentials?view=graph-bicep-1.0#resource-format
resource appRegistration 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: appUniqueName
  displayName: 'ghauth-azure-${subscriptionName}-${appUniqueName}'

  // Define the federated identity credential as a nested resource
  resource branchFederatedCredential 'federatedIdentityCredentials@v1.0' = {
    name: '${appUniqueName}/github_${githubOrg}-${githubRepo}_${githubBranch}'
    audiences: ['api://AzureADTokenExchange']
    description: 'GitHub Actions to Sub: ${subscriptionName} from Repo: ${githubOrg}/${githubRepo} Branch: ${githubBranch}'
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubOrg}/${githubRepo}:ref:refs/heads/${githubBranch}'
  }
}

// Create service principal associated with the app registration
resource servicePrincipal 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: appRegistration.appId
}

// Output values needed for GitHub Actions integration
output clientId string = appRegistration.appId
output tenantId string = tenant().tenantId
output subscriptionId string = subscription().subscriptionId
