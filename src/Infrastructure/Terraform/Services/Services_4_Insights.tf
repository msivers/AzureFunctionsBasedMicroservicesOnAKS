# ------------------------------------------
# ****** CONTAINER INSIGHTS RESOURCES ******
# ------------------------------------------

resource "azurerm_log_analytics_workspace" "services" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.res_prefix}-${var.environment}-services-log-analytics-workspace-${var.primary_location}"
    location            = var.primary_location
    resource_group_name = azurerm_resource_group.services.name
    sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "services" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.services.location
    resource_group_name   = azurerm_resource_group.services.name
    workspace_resource_id = azurerm_log_analytics_workspace.services.id
    workspace_name        = azurerm_log_analytics_workspace.services.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}