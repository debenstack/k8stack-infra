terraform {
    required_providers {
      digitalocean = {
          source = "digitalocean/digitalocean"
      }
    }
}

provider "digitalocean" {
  token = var.do_token
}

resource "random_id" "cluster_name" {
  byte_length = 5
}

locals {
  cluster_name = "k8stack-${random_id.cluster_name.hex}"
}

resource "digitalocean_kubernetes_cluster" "k8stack" {
  name    = local.cluster_name
  region  = "nyc3"
  version = "1.29.1-do.0"

  node_pool {
    name       = "main-worker-pool"
    size       = "s-2vcpu-2gb"
    auto_scale = true
    min_nodes  = 3
    max_nodes  = 5
  }
}

resource "digitalocean_project" "k8stack-project" {
  name        = "k8stack"
  description = "debenstack Kubernetes Cluster"
  purpose     = "Production debenstack Kubernetes"
  environment = "Production"
  resources   = [
    digitalocean_kubernetes_cluster.k8stack.urn
  ]
}