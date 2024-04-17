terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }

  }
}


/* Cert Manager */
resource "kubectl_manifest" "cert-manager-crds" {
  for_each          = toset(split("---", file("${abspath(path.module)}/res/cert-manager-1.14.4/cert-manager.crds.yaml")))
  yaml_body         = each.value
  server_side_apply = true
}


/* Prometheus */
resource "kubectl_manifest" "prometheus-crds" {
  for_each          = fileset("${abspath(path.module)}/res/prometheus-25.19.1", "*.yaml")
  yaml_body         = file("${abspath(path.module)}/res/prometheus-25.19.1/${each.value}")
  server_side_apply = true
}

/* Kyverno */
resource "kubectl_manifest" "kyverno-crds" {
  for_each          = fileset("${abspath(path.module)}/res/kyverno-1.11.4", "*.yaml")
  yaml_body         = file("${abspath(path.module)}/res/kyverno-1.11.4/${each.value}")
  server_side_apply = true
}

/* Elasticsearch */
resource "helm_release" "elasticsearch-crds" {
  name = "eck-operator"

  repository = "https://helm.elastic.co"
  chart      = "eck-operator-crds"

  atomic           = true
  create_namespace = true
  namespace        = "elasticsearch"
  version          = "2.12.1"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  #values = [
  #  file("${abspath(path.module)}/res/elasticsearch-crd-values.yaml")
  #]
}