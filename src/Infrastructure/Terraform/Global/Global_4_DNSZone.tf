# ----------------------
# ****** DNS ZONE ******
# ----------------------

resource "azurerm_dns_zone" "global" {
  name                = "revolutionplatform.net"
  resource_group_name = azurerm_resource_group.global.name

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}