# ------------------------------
# ****** COSMOS RESOURCES ******
# ------------------------------

resource "azurerm_cosmosdb_account" "data" {
  name                = "${var.res_prefix}-${var.environment}-cosmos"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableGremlin"
  }

  enable_automatic_failover       = var.cosmos_enable_auto_failover
  enable_multiple_write_locations = var.cosmos_enable_multiple_write_locations

  #set ip_range_filter to allow azure services (0.0.0.0) and azure portal.
  #ip_range_filter = "0.0.0.0,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.data.location
    failover_priority = 0
  }

  # Need terraform to support condition statements for blocks. Want to define multiple locations in production by not dev and test. 
  # TODO: Terraform 0.12 should support null to unassign variables - this may enable us to have this as optional?
  # geo_location {
  #   location          = "${var.failover_location}"
  #   failover_priority = 1
  # }

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
    context     = var.tag_context
  }
}

# Create database and collection (graph) on Cosmos DB
resource "null_resource" "data-create-collections" {
  triggers = {
    cosmos_id = azurerm_cosmosdb_account.data.id
  }

  # Login and set subscription
  provisioner "local-exec" {
    command = "az login --service-principal -u ${var.client_id} -p ${var.client_secret} --tenant ${var.tenant_id}"
  }
  provisioner "local-exec" {
    command = "az account set --subscription ${var.subscription_id}"
  }

  # Create Database - Graph
  provisioner "local-exec" {
    command = "az cosmosdb gremlin database create --account-name ${azurerm_cosmosdb_account.data.name} --name RevolutionDB --resource-group ${azurerm_resource_group.data.name}"
  }
  
  # Create Graph (Collection) - Main Graph
  provisioner "local-exec" {
    command = "az cosmosdb gremlin graph create -g ${azurerm_resource_group.data.name} -a ${azurerm_cosmosdb_account.data.name} -d RevolutionDB -n RevolutionGraph --partition-key-path ${var.cosmos_partition_key_graph} --throughput ${var.cosmos_throughput_graph}"
  }

  # Create Graph (Collection) - Reference Data - used for just entities as though documents. TODO: Would be more efficient and cost effective to simply use another Cosmos DB, or Tables in Storage Account?
  provisioner "local-exec" {
    command = "az cosmosdb gremlin graph create -g ${azurerm_resource_group.data.name} -a ${azurerm_cosmosdb_account.data.name} -d RevolutionDB -n RevolutionRefData --partition-key-path ${var.cosmos_partition_key_reference} --throughput ${var.cosmos_throughput_reference}"
  }

  depends_on = [azurerm_cosmosdb_account.data]
}

