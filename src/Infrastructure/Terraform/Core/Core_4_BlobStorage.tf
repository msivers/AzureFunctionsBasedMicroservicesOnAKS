# --------------------------
# ****** BLOB STORAGE ******
# --------------------------

resource "azurerm_storage_account" "core" {
  name                     = "${var.res_prefix}${var.environment}stor${var.primary_location}"
  resource_group_name      = azurerm_resource_group.core.name
  location                 = var.primary_location
  account_kind             = "StorageV2"
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_storage_container" "core_functions" {
  name                  = "azurewebjobsstorage"
  storage_account_name  = azurerm_storage_account.core.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "core_media_public" {
  name                  = "media-public"
  storage_account_name  = azurerm_storage_account.core.name
  container_access_type = "blob"
}

resource "azurerm_storage_container" "core_media_private" {
  name                  = "media-private"
  storage_account_name  = azurerm_storage_account.core.name
  container_access_type = "private"
}