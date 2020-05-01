# -----------------------------
# ****** RESOURCE GROUPS ******
# -----------------------------

resource "azurerm_resource_group" "data" {
  name     = "${var.res_prefix}-${var.environment}-data-rg"
  location = var.primary_location

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

data "azurerm_resource_group" "core" {
  name = "${var.res_prefix}-${var.environment}-core-rg"
}

data "azurerm_resource_group" "global" {
  name = "${var.res_prefix}-global-rg"
}

