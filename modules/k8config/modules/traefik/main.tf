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
    templatefile(format("%s%s", path.module , "/res/traefik-ingress-values.yaml.tftpl"), {
      domain = var.domain
    })
  ]

  depends_on = [ 
    #kubernetes_secret.cloudflare_api_credentials
  ]
}


resource "random_password" "password" {
  length           = 25
  special          = false
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "traefik_dashboard_password" {
  metadata {
    name = "traefik-dashboard-auth-password"
    namespace = "traefik"
  }

  type = "kubernetes.io/basic-auth"

  data = {
    username = "traefik-dashboard-admin"
    password = random_password.password.result
  }

  depends_on = [ 
    helm_release.traefik_ingress
   ]
}
