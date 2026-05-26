output "release_name" {
  value       = helm_release.this.name
  description = "Name of the Schema Registry Helm release."
}

output "release_namespace" {
  value       = helm_release.this.namespace
  description = "Namespace of the Schema Registry Helm release."
}

output "release_status" {
  value       = helm_release.this.status
  description = "Status of the Schema Registry Helm release."
}

output "release_chart_version" {
  value       = helm_release.this.version
  description = "Chart version used for the Schema Registry Helm release."
}

output "helm_metadata" {
  value       = helm_release.this.metadata
  description = "Helm release metadata for the deployed Schema Registry release."
}

output "service_name" {
  value       = helm_release.this.name
  description = "Kubernetes Service name for the Schema Registry release (matches release name)."
}

output "ingress_hostnames" {
  value       = local.ingress_enabled && var.hostname != null ? [var.hostname] : []
  description = "Ingress hostnames configured when ingress is enabled."
}
