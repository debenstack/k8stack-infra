# k8stack-infra
K8 Stack for debenstack

# Prerequisites
- `kubectl` installed
- `terraform` installed
- `doctl` installed

# Setup
1. Clone the repository
2. `cd` to the project root
3. Setup your cluster by initialising and then applying terraform
    ````bash
    terraform init
    terraform apply
    ```
4. Set your kubectl config by fetching your cluster name from the Terraform outputs and passing it to `doctl`
    ```bash
    doctl kubernetes cluster kubeconfig save $(terraform output -raw cluster_name)
    ```

# Developer Resources
* https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster
* https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins


* https://github.com/digitalocean/terraform-provider-digitalocean/tree/main/examples/kubernetes
* https://docs.digitalocean.com/products/kubernetes/
* https://github.com/digitalocean/terraform-provider-digitalocean/blob/main/examples/kubernetes/kubernetes-config/main.tf

* https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

* https://github.com/debenstack/k8s-bootstrapper/blob/main/infrastructure/terraform/README.md

## Helm
* https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#example-usage---chart-repository

## Cert Manager
* https://cert-manager.io/docs/concepts/issuer/
* https://traefik.io/blog/secure-web-applications-with-traefik-proxy-cert-manager-and-lets-encrypt/
* https://letsencrypt.org/docs/staging-environment/?ref=traefik.io
* https://artifacthub.io/packages/helm/cert-manager/cert-manager

## Traefik Ingress
* https://github.com/bluepuma77/traefik-best-practice/blob/main/docker-traefik-dashboard-letsencrypt/docker-compose.yml
* https://go-acme.github.io/lego/dns/cloudflare/
* https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret
* https://github.com/mrunkel/devtools/blob/master/docker-compose.yml
* https://www.reddit.com/r/Traefik/comments/104anfb/issues_generating_letsencrypt_certs_with/?onetap_auto=true&one_tap=true
* https://artifacthub.io/packages/helm/traefik/traefik/9.2.0
* https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml?ref=traefik.io

## Terraform
* https://developer.hashicorp.com/terraform/tutorials/configuration-language/dependencies

