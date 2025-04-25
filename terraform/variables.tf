# GitHub-related variables
variable "github_org" {
  description = "The GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "The GitHub branch name for the main branch federated credential"
  type        = string
  default     = "main"
}

variable "github_environments" {
  description = "List of GitHub environments to create federated credentials for"
  type        = list(string)
  default     = []
}

variable "github_token" {
  description = "GitHub personal access token with repo permissions (required if create_github_secrets is true)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "create_github_secrets" {
  description = "Whether to create GitHub repository secrets for Azure authentication"
  type        = bool
  default     = false
}

# Azure-related variables
variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources should be created"
  type        = string
  default     = "eastus"
}

variable "role_definition_name" {
  description = "The role to assign to the service principal"
  type        = string
  default     = "Contributor"
}
