# ------------------------------------------------
# ****** AZURE CONTAINER REGISTRY RESOURCES ******
# ------------------------------------------------

resource "azurerm_container_registry" "global" {
  name                = "revolutionplatform"
  resource_group_name = azurerm_resource_group.global.name
  location            = var.primary_location
  sku                 = "Standard"
  admin_enabled       = true

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

