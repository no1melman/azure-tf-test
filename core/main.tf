terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.64.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {

  }
}

variable "subscription_environment" {
  default = "monzo"
}

variable "resource_location_pretty" {
  default = "uks"
}

variable "resource_location" {
  default = "uksouth"
}

variable "application_name" {
  default = "tf"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.subscription_environment}-${var.resource_location_pretty}-${var.application_name}-rg"
  location = var.resource_location
}

resource "azurerm_storage_account" "tfstatestore" {
  name                     = "tfuksstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}

resource "azurerm_storage_container" "tfstatecontainer" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstatestore.name
  container_access_type = "private"
}
