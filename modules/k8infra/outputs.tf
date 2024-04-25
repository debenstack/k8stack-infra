output "cluster_id" {
  value = digitalocean_kubernetes_cluster.k8stack.id
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.k8stack.name
}




output "resource_bucket_name" {
  value = digitalocean_spaces_bucket.k8stack-resources.name
}

output "resource_bucket_endpoint" {
  value = digitalocean_spaces_bucket.k8stack-resources.endpoint
}

output "resource_bucket_region" {
  value = digitalocean_spaces_bucket.k8stack-resources.region
}