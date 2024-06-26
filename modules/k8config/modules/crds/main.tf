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

/* MySQL Operator */
resource "kubectl_manifest" "mysql-operator-crds" {
  for_each          = toset(split("---", file("${abspath(path.module)}/res/mysql-operator-8.4.0-2.1.3/crd.yaml")))
  yaml_body         = each.value
  server_side_apply = true
}