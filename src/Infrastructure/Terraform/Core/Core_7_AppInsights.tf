# --------------------------------------------
# ****** APPLICATION INSIGHTS RESOURCES ******
# --------------------------------------------

resource "azurerm_application_insights" "core" {
  name                = "${var.res_prefix}-${var.environment}-appinsights"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.core.name
  application_type    = "Other"

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}