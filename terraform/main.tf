
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
}

# Define some variables which are used thorough the script
locals {
	az_location = "northeurope"
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "canopus-rg"
  location = local.az_location
}

