# General

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "resource_group_name" {
  value = azurerm_resource_group.services.name
}

# Azure App Gateway

output "application_gateway_name" {
  value = azurerm_application_gateway.services.name
}

# AKS Cluster

output "client_key" {
  value = azurerm_kubernetes_cluster.services.kube_config[0].client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.services.kube_config[0].client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.services.kube_config[0].cluster_ca_certificate
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.services.name
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.services.kube_config[0].username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.services.kube_config[0].password
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.services.kube_config_raw
}

output "host" {
  value = azurerm_kubernetes_cluster.services.kube_config[0].host
}

output "identity_resource_id" {
  value = azurerm_user_assigned_identity.services.id
}

output "identity_client_id" {
  value = azurerm_user_assigned_identity.services.client_id
}