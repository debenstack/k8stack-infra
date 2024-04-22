terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}

resource "helm_release" "prometheus-adapter" {
  name = "prometheus-adapter"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-adapter"
  version    = "4.10.0"

  atomic = true

  create_namespace = true
  namespace        = "prometheus-adapter"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/prometheus-adapter-values.yaml")
  ]

}