variable "do_token" {
  description = "Digital Ocean API Auth Token"
  sensitive   = true
  type        = string
}

/*
variable "do_spaces_access_key_id" {
  description = "Digital Ocean Spaces Access Key Id"
  sensitive   = true
  type        = string
}

variable "do_spaces_secret_access_key" {
  description = "Digital Ocean Spaces Secret Access Key"
  sensitive   = true
  type        = string
}
*/

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

variable "sub_domain" {
  description = "Sub Domain That Is Prepended"
  sensitive   = true
  type        = string
  default     = ""
}


