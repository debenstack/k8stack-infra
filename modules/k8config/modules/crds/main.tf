terraform {
    required_providers {
      kubectl = {
        source = "alekc/kubectl"
        version = "2.0.4"
      }
    }
}


/* Cert Manager */
/*
data kubectl_file_documents "cert-manager-crds-docs" {
    content = file("${abspath(path.module)}/res/cert-manager-1.14.4/cert-manager.crds.yaml")
}
resource "kubectl_manifest" "cert-manager-crds" {
    for_each  = data.kubectl_file_documents.cert-manager-crds-docs.manifests
    yaml_body = each.value
}*/
resource "kubectl_manifest" "cert-manager-crds" {
    for_each  = toset(split("---", file("${abspath(path.module)}/res/cert-manager-1.14.4/cert-manager.crds.yaml")))
    yaml_body = each.value
    server_side_apply = true

    #wait_for {
    #  field {
    #    key = "status.conditions[0].type"
    #    value = "NamesAccepted"
    #  }
    #}
}


/* Prometheus */
resource "kubectl_manifest" "prometheus-crds" {
  for_each  = fileset("${abspath(path.module)}/res/prometheus-25.19.1", "*.yaml")
  yaml_body = file("${abspath(path.module)}/res/prometheus-25.19.1/${each.value}")
  server_side_apply = true

  #wait_for {
  #  field {
  #    key = "status.conditions[0].type"
  #    value = "NamesAccepted"
  #  }
  #}
}

