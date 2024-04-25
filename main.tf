terraform {
  required_version = "~> 1.8.1"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.36.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}


module "k8infra" {
  source = "./modules/k8infra"

  providers = {
    digitalocean = digitalocean
    cloudflare   = cloudflare
  }

  domain     = var.domain
  sub_domain = var.sub_domain
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [module.k8infra]
  create_duration = "60s"
}

module "k8config" {
  source = "./modules/k8config"

  cluster_id   = module.k8infra.cluster_id
  cluster_name = module.k8infra.cluster_name

  cf_email = var.cf_email
  cf_token = var.cf_token
  domain   = var.sub_domain != "" ? format("%s.%s", var.sub_domain, var.domain) : var.domain

  s3_access_key_id     = var.do_spaces_access_key_id
  s3_secret_access_key = var.do_spaces_secret_access_key

  providers = {
    kubernetes = kubernetes
    helm       = helm
    kubectl    = kubectl
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]

}