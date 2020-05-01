# -------------------------------------------
# ****** Application Gateway RESOURCES ******
# -------------------------------------------

locals {
  backend_address_pool_name   = "${azurerm_virtual_network.services.name}-be-addr-pool"
  backend_http_setting_name   = "${azurerm_virtual_network.services.name}-be-http-setting"
  frontend_port_name_http     = "${azurerm_virtual_network.services.name}-fe-port-http"
  frontend_port_name_https    = "${azurerm_virtual_network.services.name}-fe-port-https"
  frontend_ip_config_name     = "${azurerm_virtual_network.services.name}-fe-ip"
  listener_name_http          = "${azurerm_virtual_network.services.name}-listener-http"
  listener_name_https         = "${azurerm_virtual_network.services.name}-listener-https"
  request_routing_rule_name   = "${azurerm_virtual_network.services.name}-req-routing-rule"
  redirect_configuration_name = "${azurerm_virtual_network.services.name}-redirect-config"
}

resource "azurerm_application_gateway" "services" {
  name                = "${var.res_prefix}-${var.environment}-services-vnet-${var.primary_location}"
  resource_group_name = azurerm_resource_group.services.name
  location            = var.primary_location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.agwsubnet.id
  }

  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.services.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.backend_http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_config_name
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_http
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_setting_name
  }

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
  }

  depends_on = [
    azurerm_virtual_network.services,
    azurerm_public_ip.services,
  ]
}

