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

variable "object_storage_access_key_id" {
  description = "S3 Compatible Object Storage - Access Key Id"
  sensitive   = true
  type        = string
  nullable    = false
}

variable "object_storage_secret_access_key" {
  description = "S3 Compatible Object Storage - Secret Access Key"
  sensitive   = true
  type        = string
  nullable    = false
}

variable "object_storage_region" {
  description = "S3 Compatible Object Storage - Region"
  sensitive   = true
  type        = string
  nullable    = false
}

variable "object_storage_endpoint" {
  description = "S3 Compatible Object Storage - Endpoint"
  sensitive   = true
  type        = string
  nullable    = false
}

variable "object_storage_bucket_name" {
  description = "S3 Compatible Object Storage - Bucket Name"
  sensitive   = true
  type        = string
  nullable    = false
}