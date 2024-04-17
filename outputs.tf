output "cluster_id" {
  value       = module.k8infra.cluster_id
  description = "The unique ID of the cluster. Needed to configure with kubectl"
}

output "cluster_name" {
  value       = module.k8infra.cluster_name
  description = "The name of the cluster. Needed to configure with kubectl"
}