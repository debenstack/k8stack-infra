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

data "digitalocean_kubernetes_versions" "cluster_version" {
  version_prefix = "1.29"
}

resource "digitalocean_kubernetes_cluster" "k8stack" {
  name    = local.cluster_name
  region  = "nyc3"
  version = data.digitalocean_kubernetes_versions.cluster_version.latest_version

  surge_upgrade = true
  auto_upgrade  = true

  tags = ["k8stack"]

  maintenance_policy {
    start_time = "7:00" 
    day = "any"
  }
  
  node_pool {
    name       = "main-worker-pool"
    size       = "s-2vcpu-2gb"

    auto_scale = true

    min_nodes  = 2
    node_count = 4
    max_nodes  = 8

    tags = ["pool-name:main-worker-pool", "resource-demand:high"]

    labels = {
      resource-demand = "high"
    }
  }
}


resource "digitalocean_kubernetes_node_pool" "extended_pool" {
  cluster_id = digitalocean_kubernetes_cluster.k8stack.id

  name       = "extended-worker-pool"
  size       = "s-1vcpu-2gb"
  
  auto_scale = true
  
  min_nodes = 1
  node_count = 5
  max_nodes = 8

  tags = ["pool-name:extended-pool", "resource-demand:low"]

  labels = {
    resource-demand = "low"
  }

}


resource "digitalocean_project" "k8stack-project" {
  name        = "k8stack"
  description = "debenstack Kubernetes Cluster"
  purpose     = "Production debenstack Kubernetes"
  environment = "Production"
  resources = [
    digitalocean_kubernetes_cluster.k8stack.urn,
    digitalocean_spaces_bucket.k8stack-resources.urn
  ]
}

resource "digitalocean_spaces_bucket" "k8stack-resources" {
  name   = "k8stack-resources"
  region = "nyc3"
  acl = "private"

  # Deletes the bucket even if its not empty
  force_destroy = true
}


