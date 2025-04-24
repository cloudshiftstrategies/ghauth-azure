/**
 * # GitHub OIDC Integration for Azure
 *
 * This configuration sets up GitHub Actions to authenticate with Azure using OpenID Connect (OIDC).
 * Resources are organized by provider type in separate files.
 */

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0"
    }
  }
}

# Data Sources
data "azurerm_client_config" "current" {}