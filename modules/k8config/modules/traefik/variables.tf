
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

variable "domain" {
    description = "Root Domain For Service"
    sensitive = true
    type = string
}