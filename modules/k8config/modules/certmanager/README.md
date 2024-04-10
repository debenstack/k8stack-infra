# certmanager Terraform Module
This is the Terraform Module for certmanager. This module is specific to the k8stack-infra project. It can probably be used outside of the project, but it will definitly need a review and likely some modifications to make it work effectively

This module installed the cert-manager via Helm. It also installs and packages the CRDs along with it. This has pros and cons. Due to this project being a personal kubernetes cluster - I value the convenience over the reliability. For more details on this see:
* https://artifacthub.io/packages/helm/cert-manager/cert-manager

Along with Helm, Terraform installs the ClusterIssuers configured to use LetsEncrypt and Cloudflare. You can pass your Cloudflare credentials as parameters to this module.

Due to how Terraform verifies all of its resources before applying, the installation of the ClusterIssuers is a bit more dumbed down where it is only reading in the templated yaml files located in the `/res` folder of this module. It then blindly applies these to the cluster.  See https://github.com/hashicorp/terraform-provider-kubernetes/issues/1782 for more details on the issue. This dumbed down applying though gaurantees that Terraform can ensure the cert-manager CRDs are installed before applying the ClusterIssuers

See the `/res/cert-manager-values.yaml` for the override settings of the cert-manager Helm chart. See the `clusterissuer-letsencrypt-<env>.yaml.tftpl` files for the templates ClusterIssuers configurations. One is setup for staging from LetsEncrypt to avoid hitting limits. The other is their production endpoint. These yaml files are templates so that the variables retrieved from Terraform can be conveniently set in these files


# Other Resources
* https://cert-manager.io/docs/concepts/issuer/
* https://traefik.io/blog/secure-web-applications-with-traefik-proxy-cert-manager-and-lets-encrypt/
* https://letsencrypt.org/docs/staging-environment/?ref=traefik.io
* https://artifacthub.io/packages/helm/cert-manager/cert-manager

## Issues with kubectl_manifest and CRDS
* https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/kubectl_manifest
* https://github.com/gavinbunney/terraform-provider-kubectl/issues/270

## Configure Cloudflare API Token with cert-manager
* https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/

## Prometheus Scraping For CertManager:
* https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/README.template.md#prometheus