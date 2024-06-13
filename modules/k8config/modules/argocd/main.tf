
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
  }
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  atomic           = true
  create_namespace = true
  namespace        = "argocd"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/argocd-values2.yaml")
  ]
}



resource "kubectl_manifest" "argocd_ingress_certificate" {
  yaml_body = templatefile("${abspath(path.module)}/res/argocd-ingress-certificate.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.argocd
  ]
}

resource "kubectl_manifest" "argocd_ingress" {
  yaml_body = templatefile("${abspath(path.module)}/res/argocd-ingress.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.argocd,
    kubectl_manifest.argocd_ingress_certificate
  ]
}