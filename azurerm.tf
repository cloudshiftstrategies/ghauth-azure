# Azure Resource Manager Resources
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 1. Create the Azure resource group
resource "azurerm_resource_group" "github_oidc" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    purpose = "github-oidc"
  }
}

# 2. Assign the specified role to the service principal for the resource group
resource "azurerm_role_assignment" "github_oidc" {
  scope                = azurerm_resource_group.github_oidc.id
  role_definition_name = var.role_definition_name
  principal_id         = azuread_service_principal.github_oidc.object_id
}
