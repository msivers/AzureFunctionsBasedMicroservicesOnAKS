# General

output "resource_group_name" {
  value = azurerm_resource_group.core.name
}


# Blob Storage

output "storage_account_id" {
  value = azurerm_storage_account.core.id
}

output "storage_account_name" {
  value = azurerm_storage_account.core.name
}

output "storage_account_access_key" {
  value = azurerm_storage_account.core.primary_access_key
}

output "blob_service_endpoint" {
  value = azurerm_storage_account.core.primary_blob_endpoint
}

output "blob_connection_string" {
  value = azurerm_storage_account.core.primary_blob_connection_string
}

output "static_website_endpoint" {
  value = azurerm_storage_account.core.primary_web_endpoint
}


# Key Vault

output "key_vault_id" {
  value = azurerm_key_vault.core.id
}

output "key_vault_name" {
  value = azurerm_key_vault.core.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.core.vault_uri
}


# App Insights

output "application_insights_id" {
  value     = azurerm_application_insights.core.id
}

output "application_insights_name" {
  value     = azurerm_application_insights.core.name
}

output "application_insights_instrumentation_key" {
  value     = azurerm_application_insights.core.instrumentation_key
  sensitive = true
}