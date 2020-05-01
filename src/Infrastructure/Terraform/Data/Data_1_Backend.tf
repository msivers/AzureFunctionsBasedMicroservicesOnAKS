# Tokens to be replaced through token replacement task in CI/CD process 

terraform {
  backend "azurerm" {
    resource_group_name  = "#{TerraformState-RG}#"
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-Data}#"
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

data "terraform_remote_state" "core" {
  backend = "azurerm"
  config = {
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-Core}#"
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
