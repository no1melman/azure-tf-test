terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.64.0"
    }
  }
  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name  = "monzo-uks-tf-rg"
    storage_account_name = "tfuksstorageaccount"
    container_name       = "tfstate"
    key                  = "monzo.terraform.state"
  }
}

provider "azurerm" {
  features {}
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
  default = "backend"
}

resource "azurerm_resource_group" "backend_rg" {
  name     = "${var.subscription_environment}-${var.resource_location_pretty}-${var.application_name}-rg"
  location = var.resource_location
}

resource "azurerm_service_plan" "backend_app_plan" {
  name                = "${var.subscription_environment}-${var.resource_location_pretty}-${var.application_name}-appplan"
  resource_group_name = azurerm_resource_group.backend_rg.name
  location            = var.resource_location
  os_type             = "Linux"
  sku_name            = "Free"
}

resource "azurerm_linux_web_app" "backend_container" {
  name                = "${var.subscription_environment}-${var.resource_location_pretty}-${var.application_name}-linuxapp"
  resource_group_name = azurerm_resource_group.backend_rg.name
  location            = azurerm_service_plan.backend_app_plan.location
  service_plan_id     = azurerm_service_plan.backend_app_plan.id

  site_config {
    always_on = false
  }

  identity {
    type = "SystemAssigned"
  }
}
