# loki Module
This module is configured to work with S3 buckets to provide elastic storage for Log storage. Digital Ocean's blob storage (Spaces) mimmicks the AWS S3 api for compatibility and ease of integration.

This module thus is partially hardcoded with configuration settings for S3, but altered to work with Digital Ocean's implementation. You will need to look through the values files s3 configuration settings to ensure they work with your setup - whether that be Digital Ocean, AWS or another cloud provider that supports S3's blob storage protocols

# Resources
loki distributed walkthrough:
https://akyriako.medium.com/kubernetes-logging-with-grafana-loki-promtail-in-under-10-minutes-d2847d526f9e

https://www.digitalocean.com/community/developer-center/how-to-install-loki-stack-in-doks-cluster


