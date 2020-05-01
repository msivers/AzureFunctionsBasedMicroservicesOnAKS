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

# KVs - As we have single cert to cover all revolutionplatform.net subdomains - we want one process to cover all environments.
variable "kv_name_dev" {
  default = "rp-dev-kv-westeurope"
}

variable "kv_name_test" {
  default = "rp-test-kv-westeurope"
}

variable "kv_name_prod" {
  default = "rp-prod-kv-westeurope"
}

