# Tokens to be replaced through token replacement task in CI/CD process 

terraform {
  backend "azurerm" {
    resource_group_name  = "#{TerraformState-RG}#"
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-Services}#"
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

data "terraform_remote_state" "data" {
  backend = "azurerm"
  config = {
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-Data}#"
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

provider "azuread" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  version = "~> 0.3"
}


# ------------------------------
# ****** DATA DEFINITIONS ******
# ------------------------------

data "azurerm_subscription" "current" {
}

data "azurerm_key_vault_secret" "b2c_tenant_id" {
  name          = "B2CGraphApiTenantId"
  key_vault_id  = data.terraform_remote_state.core.outputs.key_vault_id
}

data "azurerm_key_vault_secret" "b2c_client_id" {
  name          = "B2CGraphApiClientId"
  key_vault_id  = data.terraform_remote_state.core.outputs.key_vault_id
}

data "azurerm_key_vault_secret" "b2c_client_secret" {
  name          = "B2CGraphApiClientSecret"
  key_vault_id  = data.terraform_remote_state.core.outputs.key_vault_id
}

data "azurerm_key_vault_secret" "revplat_ssl_cert" {
  name          = "RevPlatSslCert"
  key_vault_id  = data.terraform_remote_state.core.outputs.key_vault_id
}

data "azurerm_key_vault_secret" "revplat_ssl_cert_pfx" {
  name          = "RevPlatSslCertPfx"
  key_vault_id  = data.terraform_remote_state.core.outputs.key_vault_id
}

data "azurerm_key_vault_secret" "revplat_ssl_cert_password" {
  name          = "RevPlatSslCertPassword"
  key_vault_id  = data.terraform_remote_state.core.outputs.key_vault_id
}