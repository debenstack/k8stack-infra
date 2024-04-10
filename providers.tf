
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_kubernetes_cluster" "k8stack" {
  name = module.k8infra.cluster_name
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

provider "cloudflare" {
    email = var.cf_email
    api_token = var.cf_token
}

provider "kubectl" {
  host  = data.digitalocean_kubernetes_cluster.k8stack.endpoint
  token = data.digitalocean_kubernetes_cluster.k8stack.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.k8stack.kube_config[0].cluster_ca_certificate
  )
  load_config_file = false
  apply_retry_count = 3
}