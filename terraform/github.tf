# GitHub Resources
provider "github" {
  token = var.create_github_secrets ? var.github_token : ""
  owner = var.github_org
}

# Create GitHub repository secrets for Azure authentication (optional)
resource "github_actions_secret" "azure_client_id" {
  count           = var.create_github_secrets ? 1 : 0
  repository      = var.github_repo
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azuread_application.github_oidc.client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  count           = var.create_github_secrets ? 1 : 0
  repository      = var.github_repo
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  count           = var.create_github_secrets ? 1 : 0
  repository      = var.github_repo
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = var.subscription_id
}
