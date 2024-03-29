output "cluster_id" {
  value = digitalocean_kubernetes_cluster.k8stack.id
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.k8stack.name
}