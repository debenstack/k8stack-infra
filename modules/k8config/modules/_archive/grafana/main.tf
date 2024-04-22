terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
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

resource "helm_release" "grafana" {
  name = "grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana-agent-operator"

  atomic = true

  # due to order of things, the namespace is created seperatly
  create_namespace = false
  namespace        = "grafana"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/grafana-agent-operator-values.yaml")
  ]

  depends_on = [
    kubernetes_secret.grafana_dashboard_credentials,
    kubernetes_namespace.grafana_namespace
  ]
}

resource "random_password" "password" {
  length  = 25
  special = false
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_namespace" "grafana_namespace" {
  metadata {
    name = "grafana"
  }
}

resource "kubernetes_secret" "grafana_dashboard_credentials" {
  metadata {
    name      = "grafana-dashboard-admin-credentials"
    namespace = "grafana"
  }

  data = {
    username = "grafana-dashboard-admin"
    password = random_password.password.result
  }

  depends_on = [
    kubernetes_namespace.grafana_namespace
  ]
}

resource "kubectl_manifest" "grafana_ingress_certificate" {
  yaml_body = templatefile("${abspath(path.module)}/res/grafana-ingress-certificate.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.grafana
  ]
}

resource "kubectl_manifest" "grafana_ingress" {
  yaml_body = templatefile("${abspath(path.module)}/res/grafana-ingress.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.grafana,
    kubectl_manifest.grafana_ingress_certificate
  ]
}