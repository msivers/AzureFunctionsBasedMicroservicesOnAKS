# Tokens to be replaced through token replacement task in CI/CD process 

terraform {
  backend "azurerm" {
    resource_group_name  = "#{TerraformState-RG}#"
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-UserService}#"
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

data "terraform_remote_state" "services" {
  backend = "azurerm"
  config = {
    storage_account_name = "#{TerraformState-SA}#"
    container_name       = "#{TerraformState-Container}#"
    key                  = "#{TerraformState-Key-Services}#"
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

provider "kubernetes" {
  host                   = data.terraform_remote_state.services.outputs.host
  client_certificate     = base64decode(data.terraform_remote_state.services.outputs.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.services.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.services.outputs.cluster_ca_certificate)
  load_config_file       = "false"
  version                = "1.10.0" # Pinned as v1.11.0 is broken
}

provider "helm" {
  debug = "true"
  kubernetes {
    host                   = data.terraform_remote_state.services.outputs.host
    client_certificate     = base64decode(data.terraform_remote_state.services.outputs.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.services.outputs.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.services.outputs.cluster_ca_certificate)
    load_config_file       = "false"
  }
}