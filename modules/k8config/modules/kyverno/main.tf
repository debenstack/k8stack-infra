
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

resource "helm_release" "kyverno" {
  name = "kyverno"

  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "3.1.4"

  atomic           = true
  create_namespace = true
  namespace        = "kyverno"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/kyverno-values.yaml")
  ]
}

resource "kubectl_manifest" "kyverno-policies" {
  for_each  = fileset("${abspath(path.module)}/res/policies", "*.yaml")
  yaml_body = file("${abspath(path.module)}/res/policies/${each.value}")

  depends_on = [
    helm_release.kyverno
  ]
}
