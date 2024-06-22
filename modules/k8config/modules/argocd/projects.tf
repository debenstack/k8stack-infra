

resource "time_sleep" "wait_after_argo" {
  create_duration = "30s"
  depends_on      = [helm_release.argocd]
}

resource "kubectl_manifest" "debenstack_project" {
  yaml_body = file("${abspath(path.module)}/res/projects/debenstack-app-project.yaml")

  depends_on = [
    time_sleep.wait_after_argo
  ]
}

resource "kubectl_manifest" "projectterris_project" {
  yaml_body = file("${abspath(path.module)}/res/projects/projectterris-app-project.yaml")

  depends_on = [
    time_sleep.wait_after_argo
  ]
}


