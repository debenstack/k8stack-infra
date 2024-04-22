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