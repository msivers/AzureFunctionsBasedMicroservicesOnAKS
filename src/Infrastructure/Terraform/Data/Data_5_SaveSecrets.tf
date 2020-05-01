# -----------------------------------------
# ****** COSMOS SECRETS TO KEY VAULT ******
# -----------------------------------------

data "azurerm_key_vault" "core" {
  name                = "${var.res_prefix}-${var.environment}-kv-${var.primary_location}"
  resource_group_name = data.azurerm_resource_group.core.name
}

resource "azurerm_key_vault_secret" "cosmos-primary-key" {
  name         = "CosmosDbPrimaryKey"
  value        = azurerm_cosmosdb_account.data.primary_master_key
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "cosmos-secondary-key" {
  name         = "CosmosDbSecondaryKey"
  value        = azurerm_cosmosdb_account.data.secondary_master_key
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "cosmos-primary-readonly-key" {
  name         = "CosmosDbPrimaryReadOnlyKey"
  value        = azurerm_cosmosdb_account.data.primary_readonly_master_key
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "cosmos-secondary-readonly-key" {
  name         = "CosmosDbSecondaryReadOnlyKey"
  value        = azurerm_cosmosdb_account.data.secondary_readonly_master_key
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "cosmos-primary-connection-string" {
  name         = "CosmosDbPrimaryConnectionString"
  value        = element(azurerm_cosmosdb_account.data.connection_strings, 0)
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "cosmos-secondary-connection-string" {
  name         = "CosmosDbSecondaryConnectionString"
  value        = element(azurerm_cosmosdb_account.data.connection_strings, 1)
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "cosmos-primary-readonly-connection-string" {
  name         = "CosmosDbPrimaryReadOnlyConnectionString"
  value        = element(azurerm_cosmosdb_account.data.connection_strings, 2)
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "cosmos-secondary-readonly-connection-string" {
  name         = "CosmosDbSecondaryReadOnlyConnectionString"
  value        = element(azurerm_cosmosdb_account.data.connection_strings, 3)
  key_vault_id = data.azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

