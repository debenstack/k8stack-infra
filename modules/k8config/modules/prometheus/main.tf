terraform {
    required_providers {
      helm = {
        source  = "hashicorp/helm"
        version = ">= 2.0.1"
      }
      kubernetes = {
        source = "hashicorp/kubernetes"
        version = "2.27.0"
      }
      kubectl = {
        source = "alekc/kubectl"
        version = "2.0.4"
      }
    }
}

resource "helm_release" "prometheus" {
  name = "prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"

  atomic = true
  create_namespace = true
  namespace = "prometheus"

  recreate_pods = true
  reuse_values = true
  force_update = true
  cleanup_on_fail = true
  dependency_update = true

  values = [
    #file("${abspath(path.module)}/res/prometheus-values.yaml")
  ]
}

resource "kubectl_manifest" "prometheus_ingress_certificate" {
  yaml_body = templatefile("${abspath(path.module)}/res/prometheus-ingress-certificate.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [ 
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "prometheus_ingress" {
  yaml_body = templatefile("${abspath(path.module)}/res/prometheus-ingress.yaml.tftpl", {
    domain = var.domain
  })

  depends_on = [ 
    helm_release.prometheus,
    kubectl_manifest.prometheus_ingress_certificate
  ]
}