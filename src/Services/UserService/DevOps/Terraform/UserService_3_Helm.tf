data "helm_repository" "user_service" {
  name = "user_service"
  url  = "https://revolutionplatform.azurecr.io/helm/v1/repo"

  username = data.terraform_remote_state.global.outputs.acr_admin_username
  password = data.terraform_remote_state.global.outputs.acr_admin_password
}

resource "helm_release" "user_service" {
  name          = "${var.res_prefix}-user-service-${replace(var.chart_version,".","-")}"
  repository    = data.helm_repository.user_service.metadata[0].name
  chart         = var.chart
  version       = var.chart_version
  namespace     = "services"
  reuse_values  = true
  recreate_pods = true
  
  set {
    name  = "image.repository"
    value = "${var.image_repository}:${var.image_tag}"
  }

  set {
    name  = "ingress.host"
    value = var.ingress_host
  }
}