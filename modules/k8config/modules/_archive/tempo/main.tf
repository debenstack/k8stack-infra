terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}

resource "helm_release" "tempo" {
  name = "tempo"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"

  atomic = true

  create_namespace = true
  namespace        = "tempo"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/tempo-values.yaml")
  ]

}