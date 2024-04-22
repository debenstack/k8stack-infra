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
  }
}

resource "helm_release" "loki" {
  name = "loki"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  version = "0.79.0"

  atomic = true

  create_namespace = true
  namespace        = "loki"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/loki-distributed-values.yaml")
  ]

  depends_on = [ 
    kubernetes_namespace.loki_namespace,
    kubernetes_secret.loki_s3_credentials
   ]
}

resource "kubernetes_secret" "loki_s3_credentials" {
  metadata {
    name      = "loki-s3-credentials"
    namespace = "loki"
  }

  data = {
    S3_LOKI_SECRET_ACCESS_KEY = var.s3_secret_access_key
    S3_LOKI_ACCESS_KEY = var.s3_access_key_id
  }

  depends_on = [
    kubernetes_namespace.loki_namespace
  ]
}

resource "kubernetes_namespace" "loki_namespace" {
  metadata {
    name = "loki"
  }
}

