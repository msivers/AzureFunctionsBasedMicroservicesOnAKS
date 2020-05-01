# Tokens to be replaced through token replacement task in CI/CD process 

terraform {
  backend "azurerm" {
    resource_group_name  = "#{TerraformState-RG}#"
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-Core}#"
    access_key           = "#{TerraformState-AccessKey}#"
  }
  required_version = ">= 0.12"
}

data "terraform_remote_state" "global" {
  backend = "azurerm"
  config = {
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-Global}#"
    access_key           = "#{TerraformState-AccessKey}#"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  version         = "< 2"
}

data "azurerm_client_config" "current" {
}

data "azurerm_key_vault" "devops" {
  name                = var.devops_key_vault_name
  resource_group_name = var.devops_key_vault_rg_name
}

data "azurerm_key_vault_secret" "b2c_tenant_id" {
  name          = "B2CGraphApiTenantId-${title(var.environment)}"
  key_vault_id  = data.azurerm_key_vault.devops.id
}

data "azurerm_key_vault_secret" "b2c_client_id" {
  name          = "B2CGraphApiClientId-${title(var.environment)}"
  key_vault_id  = data.azurerm_key_vault.devops.id
}

data "azurerm_key_vault_secret" "b2c_client_secret" {
  name          = "B2CGraphApiClientSecret-${title(var.environment)}"
  key_vault_id  = data.azurerm_key_vault.devops.id
}
