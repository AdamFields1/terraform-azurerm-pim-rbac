terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "132019a4-2a34-43ba-99df-c727e8f15dc7"     //subscription id
  client_id       = "166cdc2c-317a-49d8-8771-9da98c46a275"     //applicaton id
  client_secret   = "DoY8Q~uy9VK9wy.FN8Rvc0X1MG5~7ronMJMl2aML" //application secret id (value)
  tenant_id       = "058c1c69-da24-4694-9758-e2323ba4be6f"     //azuread tenant id
}

provider "azuread" {
}

locals {
  AD_Group_Display_Name = "${var.application} ${var.mg_names} - ${var.role_definition_name}"
  roleidtruncated       = trimprefix("${data.azurerm_role_definition.role.id}", "/providers/Microsoft.Authorization/roleDefinitions/")
}

resource "azuread_group" "ad_group_1" {
  display_name            = local.AD_Group_Display_Name
  mail_enabled            = false
  security_enabled        = true
  prevent_duplicate_names = true
}

resource "random_uuid" "eligible_schedule_request_id" {
  keepers = {
    principalId      = azuread_group.ad_group_1.object_id
    roleDefinitionId = data.azurerm_role_definition.role.id
  }
}

data "azurerm_management_group" "mg_name" {
  display_name = var.mg_names
}

data "azurerm_role_definition" "role" {
  name = var.role_definition_name
}

output "MG_List" {
  value = data.azurerm_management_group.mg_name
}

resource "azurerm_management_group_template_deployment" "management_group1" {
  name                = var.deployment_name == null ? random_uuid.eligible_schedule_request_id.id : var.deployment_name
  management_group_id = data.azurerm_management_group.mg_name.id
  location            = var.location
  template_content    = file("template/pim_assignment.json")
  parameters_content = jsonencode({
    "principalId" : {
      value = azuread_group.ad_group_1.object_id
    }
    "roleDefinitionId" : {
      value = local.roleidtruncated
    }
  })
}