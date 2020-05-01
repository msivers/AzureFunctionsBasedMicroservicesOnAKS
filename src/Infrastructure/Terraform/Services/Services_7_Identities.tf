# ------------------------------------------------------
# ****** Identities and Role Assigments RESOURCES ******
# ------------------------------------------------------

# User Assigned Identities 
resource "azurerm_user_assigned_identity" "services" {
  resource_group_name = azurerm_resource_group.services.name
  location            = var.primary_location

  name = "${var.res_prefix}-${var.environment}-services-identity"

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
  }
}

# Role Assignments
resource "azurerm_role_assignment" "ra1" {
  scope                = data.azurerm_subnet.akssubnet.id
  role_definition_name = "Network Contributor"
  principal_id         = var.services_sp_principle_id

  depends_on = [azurerm_virtual_network.services]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.services.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.services_sp_principle_id
  depends_on           = [azurerm_user_assigned_identity.services]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.services.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.services.principal_id
  depends_on           = [azurerm_user_assigned_identity.services, azurerm_application_gateway.services]
}

resource "azurerm_role_assignment" "ra4" {
  scope                = azurerm_resource_group.services.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.services.principal_id
  depends_on           = [azurerm_user_assigned_identity.services, azurerm_application_gateway.services]
}