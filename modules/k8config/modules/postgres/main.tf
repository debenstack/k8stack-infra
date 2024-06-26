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

resource "kubernetes_namespace" "postgres_namespace" {
  metadata {
    name = "postgres"
  }
}


resource "helm_release" "postgres_operator" {
  name = "postgres-operator"

  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator"
  chart      = "postgres-operator"
  version    = "1.11.0"

  atomic = true

  create_namespace = true
  namespace        = "postgres"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/postgres-operator-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.postgres_namespace,
    #kubernetes_secret.postgres_s3_credentials
  ]

}

resource "helm_release" "postgres_operator_ui" {
  name = "postgres-operator-ui"

  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui"
  chart      = "postgres-operator-ui"

  atomic = true

  create_namespace = true
  namespace        = "postgres"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    templatefile("${abspath(path.module)}/res/postgres-operator-ui-values.yaml.tftpl", {
      domain = var.domain
    })
  ]

  depends_on = [
    kubernetes_namespace.postgres_namespace,
    helm_release.postgres_operator,
    #kubernetes_secret.postgres_s3_credentials
  ]

}

resource "kubectl_manifest" "postgres_operator_ui_certificate" {
  yaml_body = templatefile("${abspath(path.module)}/res/postgres-operator-ui-certificate.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    kubernetes_namespace.postgres_namespace,
    helm_release.postgres_operator_ui
  ]
}

resource "random_password" "postgres_operator_ui_password" {
  length  = 25
  special = false
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "postgres_operator_ui_auth_secret" {
  metadata {
    name      = "postgres-operator-ui-auth-secret"
    namespace = "traefik"
  }

  type = "kubernetes.io/basic-auth"

  data = {
    username = "postgres-operator-ui-admin"
    password = random_password.postgres_operator_ui_password.result
  }
}

resource "kubectl_manifest" "postgres_operator_ui_auth_middleware" {
  yaml_body = file("${abspath(path.module)}/res/postgres-operator-ui-middleware.yaml")
}

resource "kubectl_manifest" "postgres_operator_ui_ingress" {
  yaml_body = templatefile("${abspath(path.module)}/res/postgres-operator-ui-ingress.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    kubernetes_namespace.postgres_namespace,
    kubectl_manifest.postgres_operator_ui_certificate,
    helm_release.postgres_operator_ui,
    kubectl_manifest.postgres_operator_ui_auth_middleware
  ]
}

resource "kubernetes_secret" "postgres_s3_credentials" {
  metadata {
    name      = "postgres-s3-credentials"
    namespace = "postgres"
  }

  data = {
    AWS_ACCESS_KEY_ID       = var.object_storage_access_key_id
    AWS_SECRET_ACCESS_KEY   = var.object_storage_secret_access_key
    AWS_REGION              = var.object_storage_region
    AWS_ENDPOINT            = var.object_storage_endpoint
    WALE_S3_ENDPOINT        = var.object_storage_endpoint
    WALE_S3_BUCKET          = var.object_storage_bucket_name
    WAL_BUCKET_SCOPE_PREFIX = ""
    USE_WALG_BACKUP         = "true"
  }

  depends_on = [
    kubernetes_namespace.postgres_namespace
  ]
}

