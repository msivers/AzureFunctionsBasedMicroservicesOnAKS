# -----------------------------
# ****** RESOURCE GROUPS ******
# -----------------------------

resource "azurerm_resource_group" "global" {
  name     = "${var.res_prefix}-${var.environment}-rg"
  location = var.primary_location

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

