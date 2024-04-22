terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}

resource "helm_release" "promtail" {
  name = "promtail"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"

  atomic = true

  create_namespace = true
  namespace        = "promtail"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/promtail-values.yaml")
  ]

}