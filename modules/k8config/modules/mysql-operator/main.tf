terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
  }
}

resource "kubernetes_namespace" "mysql_namespace" {
  metadata {
    name = "mysql-operator"
  }
}

resource "helm_release" "mysql_operator" {
  name = "mysql-operator"

  repository = "https://mysql.github.io/mysql-operator/"
  chart      = "mysql-operator"
  version = "2.1.3"

  atomic = true

  create_namespace = true
  namespace        = "mysql-operator"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.mysql_namespace
  ]

}

