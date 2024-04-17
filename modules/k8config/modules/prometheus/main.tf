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

/*
resource "helm_release" "prometheus" {
  name = "prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"

  atomic = true
  create_namespace = true
  namespace = "prometheus"

  version = "v25.19.1"

  recreate_pods = true
  reuse_values = true
  force_update = true
  cleanup_on_fail = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/prometheus-values.yaml")
  ]
}
*/

resource "helm_release" "kube-prometheus-stack" {
  name = "kube-prometheus-stack"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  atomic           = true
  create_namespace = true
  namespace        = "prometheus"

  version = "v58.0.0"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/kube-prometheus-stack-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.prometheus_namespace
  ]
}



/* Prometheus */
resource "kubectl_manifest" "prometheus_ingress_certificate" {
  yaml_body = templatefile("${abspath(path.module)}/res/prometheus-ingress-certificate.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}

resource "kubectl_manifest" "prometheus_ingress" {
  yaml_body = templatefile("${abspath(path.module)}/res/prometheus-ingress.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.kube-prometheus-stack,
    kubectl_manifest.prometheus_ingress_certificate,
    kubectl_manifest.prometheus_dashboard_auth_middleware
  ]
}

resource "random_password" "prometheus_dahsboard_password" {
  length  = 25
  special = false
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "prometheus_dashboard_auth_secret" {
  metadata {
    name      = "prometheus-dashboard-auth-secret"
    namespace = "traefik"
  }

  type = "kubernetes.io/basic-auth"

  data = {
    username = "prometheus-dashboard-admin"
    password = random_password.prometheus_dahsboard_password.result
  }
}

resource "kubectl_manifest" "prometheus_dashboard_auth_middleware" {
  yaml_body = file("${abspath(path.module)}/res/prometheus-dashboard-auth.yaml")

  depends_on = [
    kubernetes_secret.prometheus_dashboard_auth_secret
  ]
}

resource "kubernetes_namespace" "prometheus_namespace" {
  metadata {
    name = "prometheus"
  }
}



/* Grafana */
resource "random_password" "grafana_password" {
  length  = 25
  special = false
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "grafana_dashboard_credentials" {
  metadata {
    name      = "grafana-dashboard-admin-credentials"
    namespace = "prometheus"
  }

  data = {
    username = "grafana-dashboard-admin"
    password = random_password.grafana_password.result
  }

  depends_on = [
    kubernetes_namespace.prometheus_namespace
  ]
}

resource "kubectl_manifest" "grafana_ingress_certificate" {
  yaml_body = templatefile("${abspath(path.module)}/res/grafana-ingress-certificate.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}

resource "kubectl_manifest" "grafana_ingress" {
  yaml_body = templatefile("${abspath(path.module)}/res/grafana-ingress.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [
    helm_release.kube-prometheus-stack,
    kubectl_manifest.grafana_ingress_certificate
  ]
}