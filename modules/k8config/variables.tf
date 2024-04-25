variable "cluster_name" {
  description = "Kubernetes Cluster Name"
  type        = string
}

variable "cluster_id" {
  description = "Kubernetes Cluster ID as given by Digital Ocean"
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

variable "s3_access_key_id" {
  description = "S3 Access Key Id"
  sensitive   = true
  type        = string
}

variable "s3_secret_access_key" {
  description = "S3 Secret Access Key"
  sensitive   = true
  type        = string
}