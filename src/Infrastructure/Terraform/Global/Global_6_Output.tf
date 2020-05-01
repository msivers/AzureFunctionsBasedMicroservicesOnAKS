# General

output "resource_group_name" {
  value = azurerm_resource_group.global.name
}

output "dns_zone_id" {
  value = azurerm_dns_zone.global.id
}

output "dns_zone_name" {
  value = azurerm_dns_zone.global.name
}

output "acr_id" {
  value = azurerm_container_registry.global.id
}

output "acr_name" {
  value = azurerm_container_registry.global.name
}

output "acr_login_server" {
  value = azurerm_container_registry.global.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.global.admin_username
}

output "acr_admin_password" {
  value = azurerm_container_registry.global.admin_password
}