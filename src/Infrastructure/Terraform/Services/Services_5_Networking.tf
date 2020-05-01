# ----------------------------------
# ****** NETWORKING RESOURCES ******
# ----------------------------------

resource "azurerm_virtual_network" "services" {
  name                = "${var.res_prefix}-${var.environment}-services-vnet-${var.primary_location}"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.services.name
  address_space       = [var.vnet_services_cidr]

  subnet {
    name           = "subnet-services-aks"
    address_prefix = var.vnet_services_subnet_aks_cidr
  }

  subnet {
    name           = "subnet-services-agw"
    address_prefix = var.vnet_services_subnet_agw_cidr
  }

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
  }
}

data "azurerm_subnet" "akssubnet" {
  name                 = "subnet-services-aks"
  virtual_network_name = azurerm_virtual_network.services.name
  resource_group_name  = azurerm_resource_group.services.name
}

data "azurerm_subnet" "agwsubnet" {
  name                 = "subnet-services-agw"
  virtual_network_name = azurerm_virtual_network.services.name
  resource_group_name  = azurerm_resource_group.services.name
}

# Public Ip 
resource "azurerm_public_ip" "services" {
  name                = "${var.res_prefix}-${var.environment}-services-publicip-${var.primary_location}"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.services.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
  }
}

# Add A record to DNS for api/services pointing to public ip from above
resource "azurerm_dns_a_record" "services" {
  name = replace(
    replace(
      replace(var.environment, "/^d.*$/", "dev-api"),
      "/^t.*$/",
      "test-api",
    ),
    "/^p.*$/",
    "api",
  )
  zone_name           = "revolutionplatform.net"
  resource_group_name = data.terraform_remote_state.global.outputs.resource_group_name
  ttl                 = 3600
  records             = ["${azurerm_public_ip.services.ip_address}"]
}

