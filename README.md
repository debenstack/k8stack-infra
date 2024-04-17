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

# So Whats In This Tech Stack ?
This is my personal preference tech stack on Kubernetes. The idea to host my personal projects, and be a learning grounds for all things kubernetes. Deployment, Observability, Security, all of it. And with it, I'm learning how to effectively deploy and manage it using the best DevOps practices I can with IaC and the likes

Below is a table of each piece installed in my cluster at the moment, and what roles they play within it

| Service | Role Within Cluster | Notes |
| ------- | ------------------- | ----- |
| Cert Manager | Self-Signed Certificate Handler | Configured to work with Cloudflare and LetsEncrypt |
| ArgoCD | Continuous Deployment | Deploy and update my personal apps |
| Traefik | Ingress Controller | |
| Kyverno | RBAC and Admissions Controller | |
| Prometheus | Observability - Metrics Server | |
| Grafana | Observability - Metrics Dashbaord | |
| Elasticsearch | Observability - Logging Database | |
| Kibana | Observability - Logging Dashboard | Coming Soon |
| Vault | Secrets Manager | Coming Soon |

Below now is another table of the tech being used for managing and configuring my Kubernetes cluster:

| Service | Role for Cluster | Notes |
| ------- | ---------------- | ----- |
| Digital Ocean | Kubernetes Cluster Host | |
| Terraform | IaC Service | |
| Github | Code Host | |
| Github Actions | Code Linting / Verification | |

# Some Future Goals
* Cloud Agnostic Deployment - Using terraform, be able to swap out which Cloud Provider you host this stack on with a parameter

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

