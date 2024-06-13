
provider "digitalocean" {
  token = var.do_token

  spaces_access_id  = var.do_spaces_access_key_id
  spaces_secret_key = var.do_spaces_secret_access_key
}

provider "kubernetes" {
  host  = module.k8infra.cluster_endpoint
  token = module.k8infra.cluster_token
  cluster_ca_certificate = base64decode(
    module.k8infra.cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = module.k8infra.cluster_endpoint
    token = module.k8infra.cluster_token
    cluster_ca_certificate = base64decode(
      module.k8infra.cluster_ca_certificate
    )
  }
}

provider "cloudflare" {
  email     = var.cf_email
  api_token = var.cf_token
}

provider "kubectl" {
  host  = module.k8infra.cluster_endpoint
  token = module.k8infra.cluster_token
  cluster_ca_certificate = base64decode(
    module.k8infra.cluster_ca_certificate
  )
  load_config_file  = false
  apply_retry_count = 3
}