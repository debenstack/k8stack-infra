terraform {

}

module "k8infra" {
    source = "./k8infra"
    do_token = var.do_token
}

module "k8config" {
    source = "./k8config"

    cluster_id = module.k8infra.cluster_id
    cluster_name = module.k8infra.cluster_name
    do_token = var.do_token
    cf_email = var.cf_email
    cf_token = var.cf_email

}