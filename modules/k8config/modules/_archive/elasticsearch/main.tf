
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

resource "helm_release" "elasticsearch" {
  name = "elasticsearch"

  repository = "https://helm.elastic.co"
  chart      = "eck-operator"

  atomic           = true
  create_namespace = true
  namespace        = "elasticsearch"
  version          = "2.12.1"

  recreate_pods     = true
  reuse_values      = true
  force_update      = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/elasticsearch-values.yaml")
  ]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [helm_release.elasticsearch]
  create_duration = "60s"
}

/*
resource "kubectl_manifest" "elasticsearch_cluster" {
  yaml_body = file("${abspath(path.module)}/res/elasticsearch.yaml")

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}
*/
