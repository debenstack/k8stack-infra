terraform {
    required_providers {
      digitalocean = {
          source = "digitalocean/digitalocean"
      }
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
  cert_manager_values = file(format("%s%s", path.module , "/res/cert-manager-values.yaml"))
  traefik_ingress_values = file(format("%s%s", path.module , "/res/traefik-ingress-values.yaml"))
}

resource "kubernetes_secret" "cloudflare_api_credentials" {
  metadata {
    name = "cloudflare-api-credentials"
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


resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"

  atomic = true
  create_namespace = true
  namespace = "cert-manager"
  version = "v1.14.4"

  recreate_pods = true
  reuse_values = true
  force_update = true
  cleanup_on_fail = true
  dependency_update = true

  values = [
    "${local.cert_manager_values}"
  ]
}


