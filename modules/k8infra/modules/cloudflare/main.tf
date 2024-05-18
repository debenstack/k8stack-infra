terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

locals {
  prometheus_domain = var.sub_domain != "" ? format("%s.%s", "prometheus", var.sub_domain) : "prometheus"
}

data "cloudflare_zones" "domain_lookup" {
  filter {
    name = var.domain
  }
}

resource "cloudflare_record" "prometheus-a" {
  zone_id = lookup(data.cloudflare_zones.domain_lookup.zones[0], "id")
  name    = local.prometheus_domain
  type    = "A"
  #value   = digitalocean_droplet.deben2.ipv4_address
  proxied = false
}


