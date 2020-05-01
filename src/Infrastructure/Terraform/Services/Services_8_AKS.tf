# ---------------------------
# ****** AKS RESOURCES ******
# ---------------------------

resource "azurerm_kubernetes_cluster" "services" {
  name       = "${var.res_prefix}-${var.environment}-services-akscluster-${var.primary_location}"
  location   = var.primary_location
  dns_prefix = "${var.res_prefix}-${var.environment}-services-${var.primary_location}"

  resource_group_name = azurerm_resource_group.services.name
  node_resource_group = "${azurerm_resource_group.services.name}-nodes"

  addon_profile {
    http_application_routing {
      enabled = false
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.services.id
    }
  }

  default_node_pool {
    name                = "defaultpool"
    type                = "VirtualMachineScaleSets"
    vm_size             = "Standard_D2_v2"
    os_disk_size_gb     = 30
    vnet_subnet_id      = data.azurerm_subnet.akssubnet.id
    enable_auto_scaling = true
    node_count          = var.node_count
    min_count           = var.node_min_count
    max_count           = var.node_max_count
    max_pods            = var.node_max_pods
  }

  service_principal {
    client_id     = var.services_sp_client_id
    client_secret = var.services_sp_client_secret
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
  }

  tags = {
    environment = var.tag_env
    platform    = var.tag_plat
  }

  depends_on = [
    azurerm_virtual_network.services,
    azurerm_application_gateway.services,
  ]

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
    ]
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.services.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.services.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.services.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.services.kube_config[0].cluster_ca_certificate)
  load_config_file       = "false"
  version                = "1.10.0" # Pinned as v1.11.0 is broken
}

data "external" "export-cert" {
  program = ["bash", "./RP_Export_Ssl_Cert.sh"]

  query = {
    cert = data.azurerm_key_vault_secret.revplat_ssl_cert.value
    key = var.client_secret
  }
}

resource "kubernetes_secret" "tls-secret" {
  type  = "kubernetes.io/tls"

  metadata {
    name      = "api-revplat-tls"
    namespace = "services"
  }

  data = {
    "tls.crt" = data.external.export-cert.result.crt
    "tls.key" = data.external.export-cert.result.key
  }
  
  depends_on = [data.external.export-cert]
}

resource "kubernetes_secret" "services-core" {
  metadata {
    name = "core"
    namespace = "services"
  }

  data = {
    AppInsightsInstrumentationKey = data.terraform_remote_state.core.outputs.application_insights_instrumentation_key
    AzureWebJobStorage            = data.terraform_remote_state.core.outputs.blob_connection_string
  }
}

resource "kubernetes_secret" "services-graph" {
  metadata {
    name = "graph"
    namespace = "services"
  }

  data = {
    CosmosHost              = data.terraform_remote_state.data.outputs.cosmos_host
    CosmosEndpoint          = data.terraform_remote_state.data.outputs.cosmos_endpoint
    CosmosGremlinHost       = data.terraform_remote_state.data.outputs.cosmos_gremlin_host
    CosmosGremlinEndpoint   = data.terraform_remote_state.data.outputs.cosmos_gremlin_endpoint
    CosmosKey               = data.terraform_remote_state.data.outputs.cosmos-primary-key
    CosmosConnectionString  = data.terraform_remote_state.data.outputs.cosmos-primary-connection-string
  }
}

resource "kubernetes_secret" "services-identity" {
  metadata {
    name      = "identity"
    namespace = "services"
  }

  data = {
    B2CGraphApiTenant       = data.azurerm_key_vault_secret.b2c_tenant_id.value
    B2CGraphApiClientId     = data.azurerm_key_vault_secret.b2c_client_id.value
    B2CGraphApiClientSecret = data.azurerm_key_vault_secret.b2c_client_secret.value
  }
}