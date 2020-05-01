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
  default = "Services"
}

variable "primary_location" {
  default = "westeurope"
}

# Networking
variable "vnet_services_cidr" {
  default = "15.0.0.0/8"
}

variable "vnet_services_subnet_aks_cidr" {
  default = "15.100.0.0/16"
}

variable "vnet_services_subnet_agw_cidr" {
  default = "15.99.0.0/16"
}

variable "aks_dns_service_ip" {
  default = "10.100.0.10"
}

variable "aks_docker_bridge_cidr" {
  default = "172.17.0.1/16"
}

variable "aks_service_cidr" {
  default = "10.100.0.0/16"
}

# AKS Cluster

variable "vm_size" {
  default = "Standard_D2_v2"
}

variable "node_count" {
  default = 1
}

variable "node_min_count" {
  default = 1
}

variable "node_max_count" {
  default = 3
}

variable "node_max_pods" {
  default = 30
}

variable "services_sp_principle_id" {
  default = ""
}

variable "services_sp_client_id" {
  default = ""
}

variable "services_sp_client_secret" {
  default = ""
}