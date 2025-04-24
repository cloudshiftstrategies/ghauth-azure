# Azure AD Resources
provider "azuread" {
  # No explicit configuration needed for azuread provider when using CLI auth
}


# 1. Create the Azure AD application registration
resource "azuread_application" "github_oidc" {
  display_name = "GitHub-OIDC-${var.github_org}-${var.github_repo}"
}

# 2. Create a service principal associated with the application
resource "azuread_service_principal" "github_oidc" {
  client_id = azuread_application.github_oidc.client_id
}

# 3. Create federated credential for the main branch
resource "azuread_application_federated_identity_credential" "main_branch" {
  application_id = azuread_application.github_oidc.id
  display_name   = "github-main-branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
}

# 4. Create federated credential for pull requests (optional)
resource "azuread_application_federated_identity_credential" "pull_request" {
  count          = length(var.github_environments) > 0 ? 1 : 0
  application_id = azuread_application.github_oidc.id
  display_name   = "github-pull-request"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:pull_request"
}

# 5. Create federated credential for tags/releases (optional)
resource "azuread_application_federated_identity_credential" "tags" {
  count          = length(var.github_environments) > 0 ? 1 : 0
  application_id = azuread_application.github_oidc.id
  display_name   = "github-tags"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:ref:refs/tags/*"
}

# 6. Create federated credential for environments (optional)
resource "azuread_application_federated_identity_credential" "environment" {
  count          = length(var.github_environments)
  application_id = azuread_application.github_oidc.id
  display_name   = "github-environment-${var.github_environments[count.index]}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:environment:${var.github_environments[count.index]}"
}
