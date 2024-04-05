terraform {
    required_providers {
      kubernetes = {
        source = "hashicorp/kubernetes"
        version = "2.27.0"
      }
      helm = {
        source  = "hashicorp/helm"
        version = ">= 2.0.1"
      }
      kubectl = {
        source = "alekc/kubectl"
        version = "2.0.4"
      }
    }
}

module "certmanager" {
  source = "./modules/certmanager"

  cf_email = var.cf_email
  cf_token = var.cf_token

  providers = {
    helm = helm
    kubernetes = kubernetes
    kubectl = kubectl
  }
}


module "traefik" {
  source = "./modules/traefik"

  cf_email = var.cf_email
  cf_token = var.cf_token
  domain = var.domain

  providers = {
    helm = helm
    kubernetes = kubernetes
    kubectl = kubectl
  }

  depends_on = [ 
    module.certmanager
  ]
}

module "argocd" {
  source = "./modules/argocd"

  domain = var.domain

  providers = {
    helm = helm,
    kubectl = kubectl
  }

  depends_on = [
    module.certmanager,
    module.traefik
  ]
}

module "prometheus" {
  source = "./modules/prometheus"

  domain = var.domain

  providers = {
    helm = helm
    kubernetes = kubernetes
    kubectl = kubectl
  }
}

module "grafana" {
  source = "./modules/grafana"

  domain = var.domain

  providers = {
    helm = helm
    kubernetes = kubernetes
    kubectl = kubectl
  }

  depends_on = [ 
    module.prometheus
   ]
}





