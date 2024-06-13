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
| Prometheus Adapter | Metrics for Kubernetes Metrics API | Replaces metrics-server to work with Prometheus instead |
| Grafana | Observability - Metrics & Logging Dashbaord | |
| Loki| Observability - Logging Database | |
| Promtail | Observability - Container Stdout/Stderr Log Scraping | Forwards to Loki |
| Vault | Secrets Manager | Coming Soon |
| Postgres Operator | Postgres Database / Cluster Provider | Handling Postgres Databases for my personal apps |
| MySQL Operator | MySQL Database / Cluster Provider | Coming Soon |
| MongoDB Operator | MongoDB Database / Cluster Provider | Coming Soon |

Below now is another table of the tech being used for managing and configuring my Kubernetes cluster:

| Service | Role for Cluster | Notes |
| ------- | ---------------- | ----- |
| Digital Ocean | Kubernetes Cluster Host | |
| Terraform | IaC Service | |
| Github | Code Host | |
| Github Actions | Code Linting / Verification | |
| Cloudflare | DNS Provider | |

# Some Future Goals
* Cloud Agnostic Deployment - Using terraform, be able to swap out which Cloud Provider you host this stack on with a parameter
* Settings to Enable/Disable Database Operators




# Developer Resources
See each module for README for module specific resources and documentation. The following is more general documentation and guides I used for setting up this cluster properly

## Kubernetes
* https://docs.digitalocean.com/products/kubernetes/
* https://github.com/debenstack/k8s-bootstrapper/blob/main/infrastructure/terraform/README.md

## Helm
* https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#example-usage---chart-repository

## Terraform
* https://developer.hashicorp.com/terraform/tutorials/configuration-language/dependencies
* https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster
* https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins
* https://github.com/digitalocean/terraform-provider-digitalocean/tree/main/examples/kubernetes
* https://github.com/digitalocean/terraform-provider-digitalocean/blob/main/examples/kubernetes/kubernetes-config/main.tf
* https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

