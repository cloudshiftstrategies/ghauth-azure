# Outputs
output "client_id" {
  description = "The client ID (application ID) of the created application"
  value       = azuread_application.github_oidc.client_id
}

output "tenant_id" {
  description = "The Azure AD tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  description = "The Azure subscription ID"
  value       = var.subscription_id
}

output "resource_group_name" {
  description = "The name of the resource group for GitHub Actions workflows"
  value       = var.resource_group_name
}
