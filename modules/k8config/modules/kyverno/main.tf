
terraform {
    required_providers {
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

resource "helm_release" "kyverno" {
  name = "kyverno"

  repository = "https://kyverno.github.io/kyverno/"
  chart = "kyverno"

  atomic = true
  create_namespace = true
  namespace = "kyverno"

  recreate_pods = true
  reuse_values = true
  force_update = true
  cleanup_on_fail = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/kyverno-values.yaml")
  ]
}
