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

variable "load_balancer_ip" {
  description = "IP of the LoadBalancer"
  sensitive   = false
  type        = string
}