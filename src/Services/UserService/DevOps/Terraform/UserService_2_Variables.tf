# -----------------------
# ****** VARIABLES ******
# -----------------------

# Service Principle Credentials
variable "subscription_id" { default = "" }
variable "client_id" { default = "" }
variable "client_secret" { default = "" }
variable "tenant_id" { default = "" }

# General
variable "res_prefix" { default = "rp" }

# Helm/App Related
variable "chart" { default = "rp-user-service.tgz" }
variable "chart_version" { default = "latest" }
variable "image_repository" { default = "revolutionplatform.azurecr.io/revplat-services/rp-user-service" }
variable "image_tag" { default = "latest" }
variable "ingress_host" { default = "dev-api.revolutionplatform.net" }