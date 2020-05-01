# ---------------------------------------
# ****** SAVE SECRETS TO KEY VAULT ******
# ---------------------------------------

resource "azurerm_key_vault_secret" "blob_storage_conn_str" {
  name         = "StorageAccountBlobConnString"
  value        = azurerm_storage_account.core.primary_blob_connection_string
  key_vault_id = azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }

  depends_on = [azurerm_key_vault_access_policy.core]
}

resource "azurerm_key_vault_secret" "app_insights_instkey" {
  name         = "AppInsightsInstrumentationKey"
  value        = azurerm_application_insights.core.instrumentation_key
  key_vault_id = azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }

  depends_on = [azurerm_key_vault_access_policy.core]
}