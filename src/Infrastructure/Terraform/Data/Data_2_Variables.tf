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
  default = "Data"
}

variable "primary_location" {
  default = "westeurope"
}

# Cosmos DB
variable "cosmos_enable_auto_failover" {
  default = "false"
}

variable "cosmos_enable_multiple_write_locations" {
  default = "false"
}

variable "cosmos_partition_key_graph" {
  default = "/partitionKey"
}

variable "cosmos_partition_key_reference" {
  default = "/partitionKey"
}

variable "cosmos_throughput_graph" {
  default = "400"
}

variable "cosmos_throughput_reference" {
  default = "400"
}

