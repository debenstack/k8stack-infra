terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}

module "crds" {
  source = "./modules/crds"

  providers = {
    kubectl = kubectl
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [module.crds]
  create_duration = "60s"
}

module "certmanager" {
  source = "./modules/certmanager"

  cf_email = var.cf_email
  cf_token = var.cf_token

  providers = {
    helm       = helm
    kubernetes = kubernetes
    kubectl    = kubectl
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}


module "traefik" {
  source = "./modules/traefik"

  cf_email = var.cf_email
  cf_token = var.cf_token
  domain   = var.domain

  providers = {
    helm = helm
  }

  depends_on = [
    module.certmanager,
    time_sleep.wait_60_seconds
  ]
}

module "argocd" {
  source = "./modules/argocd"

  domain = var.domain

  providers = {
    helm    = helm,
    kubectl = kubectl
  }

  depends_on = [
    module.certmanager,
    module.traefik,
    time_sleep.wait_60_seconds
  ]
}


module "prometheus" {
  source = "./modules/prometheus"

  domain = var.domain

  providers = {
    helm       = helm
    kubernetes = kubernetes
    kubectl    = kubectl
  }

  depends_on = [
    module.certmanager,
    module.traefik,
    time_sleep.wait_60_seconds
  ]
}


module "kyverno" {
  source = "./modules/kyverno"

  providers = {
    kubectl = kubectl
    helm    = helm
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}


module "loki" {
  source = "./modules/loki"

  s3_access_key_id     = var.object_storage_access_key_id
  s3_secret_access_key = var.object_storage_secret_access_key

  providers = {
    helm = helm
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

module "promtail" {
  source = "./modules/promtail"

  providers = {
    helm = helm
  }

  depends_on = [
    time_sleep.wait_60_seconds,
    module.loki
  ]
}


module "prometheus-adapter" {
  source = "./modules/prometheus-adapter"

  providers = {
    helm = helm
  }

  depends_on = [
    time_sleep.wait_60_seconds,
    module.prometheus
  ]
}

module "postgres-operator" {
  source = "./modules/postgres"

  domain                           = var.domain
  object_storage_access_key_id     = var.object_storage_access_key_id
  object_storage_secret_access_key = var.object_storage_secret_access_key
  object_storage_endpoint          = var.object_storage_endpoint
  object_storage_region            = var.object_storage_region
  object_storage_bucket_name       = var.object_storage_bucket_name
  providers = {
    helm       = helm
    kubectl    = kubectl
    kubernetes = kubernetes
  }

  depends_on = [
    time_sleep.wait_60_seconds,
    module.certmanager,
    module.traefik
  ]
}

module "mysql-operator" {
  source = "./modules/mysql-operator"

  domain = var.domain

  providers = {
    helm       = helm
    kubectl    = kubectl
    kubernetes = kubernetes
  }

  depends_on = [
    time_sleep.wait_60_seconds,
    module.certmanager,
    module.traefik
  ]
}
