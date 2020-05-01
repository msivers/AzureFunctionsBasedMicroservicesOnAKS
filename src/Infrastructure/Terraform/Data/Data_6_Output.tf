# General

output "resource_group_name" {
  value = azurerm_resource_group.data.name
}


# Cosmos Outputs
output "cosmos_name" {
  value = azurerm_cosmosdb_account.data.name
}

output "cosmos_host" {
  value = "${azurerm_cosmosdb_account.data.name}.documents.azure.com"
}

output "cosmos_gremlin_host" {
  value = "${azurerm_cosmosdb_account.data.name}.gremlin.cosmosdb.azure.com"
}

output "cosmos_endpoint" {
  value = azurerm_cosmosdb_account.data.endpoint
}

output "cosmos_gremlin_endpoint" {
  value = "https://${azurerm_cosmosdb_account.data.name}.gremlin.cosmosdb.azure.com:443/"
}

output "cosmos-primary-key" {
  value = azurerm_cosmosdb_account.data.primary_master_key
  sensitive = true
}

output "cosmos-secondary-key" {
  value = azurerm_cosmosdb_account.data.secondary_master_key
  sensitive = true
}

output "cosmos-primary-readonly-key" {
  value = azurerm_cosmosdb_account.data.primary_readonly_master_key
  sensitive = true
}

output "cosmos-secondary-readonly-key" {
  value = azurerm_cosmosdb_account.data.secondary_readonly_master_key
  sensitive = true
}

output "cosmos-primary-connection-string" {
  value = element(azurerm_cosmosdb_account.data.connection_strings, 0)
  sensitive = true
}

output "cosmos-secondary-connection-string" {
  value = element(azurerm_cosmosdb_account.data.connection_strings, 1)
  sensitive = true
}

output "cosmos-primary-readonly-connection-string" {
  value = element(azurerm_cosmosdb_account.data.connection_strings, 2)
  sensitive = true
}

output "cosmos-secondary-readonly-connection-string" {
  value = element(azurerm_cosmosdb_account.data.connection_strings, 3)
  sensitive = true
}