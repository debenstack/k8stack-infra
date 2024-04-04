
terraform {
    required_providers {
      helm = {
        source  = "hashicorp/helm"
        version = ">= 2.0.1"
      }
    }
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"

  atomic = true
  create_namespace = true
  namespace = "argocd"

  recreate_pods = true
  reuse_values = true
  force_update = true
  cleanup_on_fail = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/argocd-values.yaml")
  ]
}