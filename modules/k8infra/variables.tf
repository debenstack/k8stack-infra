variable "domain" {
  description = "Root Domain For Service"
  sensitive   = true
  type        = string
}

variable "sub_domain" {
  description = "Root Domain For Service"
  sensitive   = true
  type        = string
}

variable "object_storage_region" {
  description = "S3 Compatible Object Storage - Region"
  sensitive   = true
  type        = string
}