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
    }
}


locals {
  traefik_ingress_values = file(format("%s%s", path.module , "/res/traefik-ingress-values.yaml"))
}

resource "kubernetes_secret" "cloudflare_api_credentials" {
  metadata {
    name = "cloudflare-api-credentials"
    namespace = "cert-manager"
  }

  data = {
    email = var.cf_email
    apiKey = var.cf_token
  }
}


resource "helm_release" "traefik_ingress" {
  name = "traefik-ingress-controller"

  repository = "https://helm.traefik.io/traefik"
  chart = "traefik"

  atomic = true
  create_namespace = true
  namespace = "traefik"

  recreate_pods = true
  reuse_values = true
  force_update = true
  cleanup_on_fail = true
  dependency_update = true

  values = [
    "${local.traefik_ingress_values}"
  ]

  depends_on = [ 
    kubernetes_secret.cloudflare_api_credentials
  ]
}

module "certmanager" {
  source = "./modules/certmanager"

  cf_email = var.cf_email
  cf_token = var.cf_token
  cluster_name = var.cluster_name

  providers = {
    helm = helm
    kubernetes = kubernetes
  }
}





