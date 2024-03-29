
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_kubernetes_cluster" "k8stack" {
  name = var.cluster_name
}

provider "kubernetes" {
  host             = data.digitalocean_kubernetes_cluster.k8stack.endpoint
  token            = data.digitalocean_kubernetes_cluster.k8stack.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.k8stack.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.k8stack.endpoint
    token = data.digitalocean_kubernetes_cluster.k8stack.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.k8stack.kube_config[0].cluster_ca_certificate
    )
  }
}