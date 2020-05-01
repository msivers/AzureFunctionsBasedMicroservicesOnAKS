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
  default = "global"
}

variable "tag_env" {
  default = "Global"
}

variable "tag_plat" {
  default = "Revolution"
}

variable "tag_context" {
  default = "Global"
}

variable "primary_location" {
  default = "westeurope"
}

