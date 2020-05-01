output "chart_name" {
  value = helm_release.user_service.metadata[0].chart
}

output "release_name" {
  value = helm_release.user_service.metadata[0].name
}

output "status" {
  value = helm_release.user_service.status
}

output "revision" {
  value = helm_release.user_service.metadata[0].revision
}

output "version" {
  value = helm_release.user_service.metadata[0].version
}