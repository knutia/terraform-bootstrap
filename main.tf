terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.9"
    }
  }
}


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "state" {
  name = var.resource_group_name
}

resource "azurerm_management_lock" "terraform-resource-group" {
  name       = "terraform"
  scope      = data.azurerm_resource_group.state.id
  lock_level = "CanNotDelete"
  notes      = "Protects the terraform state files and key vault."
}

locals {
  location = coalesce(var.location, data.azurerm_resource_group.state.location)
  tags     = merge(data.azurerm_resource_group.state.tags, var.tags)
}
