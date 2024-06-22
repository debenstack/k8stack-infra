output "cluster_id" {
  value = digitalocean_kubernetes_cluster.k8stack.id
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.k8stack.name
}

output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.k8stack.endpoint
}

output "cluster_token" {
  value = digitalocean_kubernetes_cluster.k8stack.kube_config[0].token
}

output "cluster_ca_certificate" {
  value = digitalocean_kubernetes_cluster.k8stack.kube_config[0].cluster_ca_certificate
}


output "object_storage_bucket_name" {
  value = digitalocean_spaces_bucket.k8stack-resources.name
}

output "object_storage_bucket_endpoint" {
  value = digitalocean_spaces_bucket.k8stack-resources.endpoint
}

output "object_storage_bucket_region" {
  value = digitalocean_spaces_bucket.k8stack-resources.region
}