variable "do_token" {
  description = "Digital Ocean API Auth Token"
  sensitive   = true
  type        = string
}

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


