variable "cluster_name" {
  description = "Kubernetes Cluster Name"
  type        = string
}

variable "cluster_id" {
  description = "Kubernetes Cluster ID as given by Digital Ocean"
  type        = string
}

variable "do_token" {
  description = "Digital Ocean API Auth Token"
  sensitive   = true
  type        = string
}

variable "cf_token" {
  description = "CloudFlare API Auth Token"
  sensitive   = true
  type        = string
}

variable "cf_email" {
  description = "CloudFlare Email Account"
  sensitive   = true
  type        = string
}

variable "domain" {
  description = "Root Domain For Service"
  sensitive   = true
  type        = string
}