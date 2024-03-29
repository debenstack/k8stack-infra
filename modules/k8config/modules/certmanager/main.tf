
terraform {
    required_providers {
      kubernetes = {
        source = "hashicorp/kubernetes"
        version = "2.27.0"
      }
      helm = {
        source  = "hashicorp/helm"
        version = ">= 2.0.1"
      }
      kubectl = {
        source = "gavinbunney/kubectl"
        version = "1.14.0"
      }
    }
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"

  atomic = true
  create_namespace = true
  namespace = "cert-manager"
  version = "v1.14.4"

  recreate_pods = true
  reuse_values = true
  force_update = true
  cleanup_on_fail = true
  dependency_update = true

  values = [
    file("${abspath(path.module)}/res/cert-manager-values.yaml")
  ]
}

/**
KNOW BUG / ISSUE: IF the cert-manager is recreated, then terraform will fail because it tries
to validate the below ClusterIssuer resources creation. This resource type does not exist until
cert-manager is installed! depends_on essentially does not work

See https://github.com/hashicorp/terraform-provider-kubernetes/issues/1782 for more details

Temporary WorkAround: Comment out the below ClusterIssuer resource creations, then uncomment
them and run Terraform again

A more perminent solution is to wrap all of this into its own Helm chart and install and manage
it that way. The issue is that Terraform cares too much about the validity of all of its resources
and we need a way for these configurations to be ignored

# https://stackoverflow.com/questions/68511476/setup-letsencrypt-clusterissuer-with-terraform
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/kubectl_manifest

Another solution, and the one used below, is to use kubectl_manifest. This shows less change data in
the terraform plan output as it just blind diffs a text file, but it does now listen to the depends_on
attribute, so these won't be created before the cert-manager is installed

**/


resource "kubectl_manifest" "clusterissuer_letsencrypt_prod" {
  yaml_body = templatefile("${abspath(path.module)}/res/clusterissuer-letsencrypt-prod.yaml.tftpl", {
    email = var.cf_email
  })

  depends_on = [ 
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "clusterissuer_letsencrypt_dev" {
  yaml_body = templatefile("${abspath(path.module)}/res/clusterissuer-letsencrypt-dev.yaml.tftpl", {
    email = var.cf_email
  })

  depends_on = [ 
    helm_release.cert_manager
  ]
}

