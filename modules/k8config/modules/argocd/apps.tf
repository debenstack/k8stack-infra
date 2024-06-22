
resource "kubectl_manifest" "adventurewiki_app" {
  yaml_body = file("${abspath(path.module)}/res/apps/adventurewiki-app.yaml")

  depends_on = [
    kubectl_manifest.projectterris_project
  ]
}

resource "kubectl_manifest" "profile_app" {
  yaml_body = file("${abspath(path.module)}/res/apps/profile-app.yaml")

  depends_on = [
    kubectl_manifest.debenstack_project
  ]
}