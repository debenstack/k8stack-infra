terraform {
    required_providers {
      digitalocean = {
          source = "digitalocean/digitalocean"
      }
      kubernetes = {
        source = "hashicorp/kubernetes"
        version = "2.27.0"
      }
      helm = {
        source  = "hashicorp/helm"
        version = ">= 2.0.1"
      }
    }
}


module "k8infra" {
    source = "./modules/k8infra"
    do_token = var.do_token

    providers = {
      digitalocean = digitalocean
    }
}

module "k8config" {
    source = "./modules/k8config"

    cluster_id = module.k8infra.cluster_id
    cluster_name = module.k8infra.cluster_name
    do_token = var.do_token
    cf_email = var.cf_email
    cf_token = var.cf_email
    domain = var.domain

    providers = {
      kubernetes = kubernetes
      helm=helm
    }

    depends_on = [ 
        module.k8infra
     ]

}