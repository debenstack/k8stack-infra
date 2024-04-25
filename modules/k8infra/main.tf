terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.36.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
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

  surge_upgrade = true
  auto_upgrade  = true

  node_pool {
    name       = "main-worker-pool"
    size       = "s-1vcpu-2gb"
    auto_scale = true
    min_nodes  = 4
    max_nodes  = 8
  }
}

resource "digitalocean_project" "k8stack-project" {
  name        = "k8stack"
  description = "debenstack Kubernetes Cluster"
  purpose     = "Production debenstack Kubernetes"
  environment = "Production"
  resources = [
    digitalocean_kubernetes_cluster.k8stack.urn
  ]
}

resource "digitalocean_spaces_bucket" "k8stack-resources" {
  name   = "k8stack-resources"
  region = "nyc3"
}


