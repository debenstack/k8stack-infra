
variable "cf_token" {
    description = "CloudFlare API Auth Token"
    sensitive = true
    type = string
}

variable "cf_email" {
    description = "CloudFlare Email Account"
    sensitive = true
    type = string
}

variable "cluster_name" {
  description = "Kubernetes Cluster Name"
  type = string
}