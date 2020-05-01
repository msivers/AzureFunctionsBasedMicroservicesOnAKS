# -----------------------
# ****** VARIABLES ******
# -----------------------

# Service Principle Credentials
variable "subscription_id" {
  default = ""
}

variable "client_id" {
  default = ""
}

variable "client_secret" {
  default = ""
}

variable "tenant_id" {
  default = ""
}

# General
variable "res_prefix" {
  default = "rp"
}

variable "environment" {
  default = "dev"
}

variable "tag_env" {
  default = "Development"
}

variable "tag_plat" {
  default = "Revolution"
}

variable "tag_context" {
  default = "Core"
}

variable "primary_location" {
  default = "westeurope"
}

variable "timestamp" {
  default = "202001"
}

variable "devops_key_vault_rg_name" {
  default = "rp-global-devops-rg"
}

variable "devops_key_vault_name" {
  default = "rp-global-devops-kv"
}

# Blob Storage
variable "storage_account_tier" {
  default = "Standard"
}

variable "storage_account_replication_type" {
  default = "LRS"
}

# SSL Cert
variable "hostname" {
  default = "dev-api.revolutionplatform.net"
}

# Application Insights
variable "insights_location" {
  default = "westeurope"
}