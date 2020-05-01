# ---------------------------------
# ****** KEY VAULT RESOURCES ******
# ---------------------------------

resource "azurerm_key_vault" "core" {
  name                            = "${var.res_prefix}-${var.environment}-kv-${var.primary_location}"
  location                        = var.primary_location
  resource_group_name             = azurerm_resource_group.core.name
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = true

  tenant_id = var.tenant_id

  sku_name = "premium"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

# Add KV access policy for this deploy's tenant_id/client_id
resource "azurerm_key_vault_access_policy" "core" {
  key_vault_id = azurerm_key_vault.core.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.service_principal_object_id

  key_permissions = [
    "backup",
    "create",
    "decrypt",
    "delete",
    "encrypt",
    "get",
    "import",
    "list",
    "purge",
    "recover",
    "restore",
    "sign",
    "unwrapKey",
    "update",
    "verify",
    "wrapKey",
  ]

  secret_permissions = [
    "backup",
    "delete",
    "get",
    "list",
    "purge",
    "recover",
    "restore",
    "set",
  ]

  certificate_permissions = [
    "backup",
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "purge",
    "recover",
    "restore",
    "setissuers",
    "update",
  ]
}

# Save B2C Graph API Secrets
resource "azurerm_key_vault_secret" "b2c_tenant_id" {
  name         = "B2CGraphApiTenantId"
  value        = data.azurerm_key_vault_secret.b2c_tenant_id.value
  key_vault_id = azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

resource "azurerm_key_vault_secret" "b2c_client_id" {
  name         = "B2CGraphApiClientId"
  value        = data.azurerm_key_vault_secret.b2c_client_id.value
  key_vault_id = azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}
resource "azurerm_key_vault_secret" "b2c_client_Secret" {
  name         = "B2CGraphApiClientSecret"
  value        = data.azurerm_key_vault_secret.b2c_client_secret.value
  key_vault_id = azurerm_key_vault.core.id

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}