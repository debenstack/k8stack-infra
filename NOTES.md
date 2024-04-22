# Lessons Learned From Setting Up This Cluster

## Helm Is Not Idempotent by Default

## Traefik by Default Disabled Cross-Namespace Ingress
By default this value is disabled. When searching for services or middleware or secrets located in other namespaces, Traefik will be unable to find them. To enable cross namespace ingress:

In Helm, set the following in your `values.yaml`:
```yaml
providers:
  kubernetesCRD:
    allowCrossNamespace: true
```
OR as the parameter in the `additionalArguments` section in your `values.yaml`:
```yaml
additionalArguments:
  - "--providers.kubernetescrd.allowCrossNamespace=true"
```

Once that is configured, you can then specify `namespace` values in your `IngressRoute` . Example:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-dashboard-ingress
  namespace: traefik
spec:
  entryPoints:                      # [1]
    - websecure
  routes:                           # [2]
    - kind: Rule
      match: Host(`argocd.${domain}`)
      priority: 10
      services:
        - name: argocd-server
          namespace: argocd
          port: 80
    - kind: Rule
      match: Host(`argocd.${domain}`) && Headers(`Content-Type`, `application/grpc`)
      priority: 11
      services:
        - name: argocd-server
          namespace: argocd
          port: 80
          scheme: h2c
  tls:                              # [12]
    secretName: argocd-dashboard-certificate-secret
```
Notice how this ingress for ArgoCD is created in the `traefik` namespace (metadata.namespace). And then the `services` definition within the `routes` now inclues a `namespace` section pointing to `argocd`. This allows traefik in the traefik namespace to forward traffic to ArgoCD, which has been setup in the `argocd` namespace

## The Traefik Dashboard Can Be Fully Secured With Basic Auth + Certificates From cert-manager Within its Helm Chart
Theres no documentation for this example scenario, and I guess in retropsect it is rather intuitive. But here is an example of how to set it up.

With traefik setup with Helm, configure the following in your `values.yaml`:
```yaml
ingressRoute:
  dashboard:
    enabled: true
    entryPoints:
      - websecure
    matchRule: Host(`traefik.yourdomain.com`)
    middlewares:
      - name: traefik-dashboard-auth
    tls:
      secretName: traefik-dashboard-certificate-secret
```
This part is the Helm chart configuration that is converted into an IngressRoute, including the TLS configuration

Next, define the following also in your `values.yaml`:
```yaml
extraObjects:
  # Generate the Middleware for authentication for the Traefik Dashboard
  - apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: traefik-dashboard-auth
    spec:
      basicAuth:
        secret: traefik-dashboard-auth-password
  # Generate the Certificate from certmanager for the Traefik Dashboard
  - apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: traefik-dashboard-certificate
      namespace: traefik
    spec:
      secretName: traefik-dashboard-certificate-secret
      dnsNames:
        - "traefik.yourdomain.com"
      issuerRef:
        name: letsencrypt-dev-cluster-issuer
        kind: ClusterIssuer
```
This portion of the helm chart configures extra templates with the deployment. For securing the dashboard, this is a middleware template to setup BasicAuth, along with a Certificate template to setup your customer certificate.

You will need to create a secret called `traefik-dashboard-auth-password` 
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: traefik-dashboard-auth-password
type: kubernetes.io/basic-auth
data:
  username: Y2hhbmdldG9hbm90aGVydXNlcm5hbWU= # changetoanotherusername
  password: Y2hhbmdldG9hZGlmZmVyZW50cGFzc3dvcmQ= # changetoadifferentpassword
```
You can also create this within `extraObjects` section above, but I did it seperatly as I didn't want my passwords sitting in my `values.yaml` file.

Once all of that is applied, the changes may not be immediate, and thats because cert-manager needs to provision your certificate still. During that time, traefik will server the website using its default built in certificate. Once the certificate is ready, traefik will be reloaded with it!

## Setup DNS01 validation with non-wildcard domains and sub-domains using cert-manager and CloudFlare
This workflow is not well documented either. But the configuration all exists, it just takes way too much digging then it should.

There at a point was actually a bug in this workflow, where cert-manager couldn't actually find the domain on cloudflare. If you run into these issues, there is a couple things you can do and try to resolve it:

1. Check your CloudFlare Token is valid and has correct permissions
2. Try using the CloudFlare Api Keys instead
3. Disable certificate validation

I would also reommend configuring the `dns01RecursiveNameservers` in your Helm `values.yaml` as this provides a list of DNS endpoints to target when validating the DNS01 Challenge. When using cloudflare, setting this to CloudFlare's DNS servers first will help speedup the challenge process as CloudFlare will likely be the quickest to update their DNS servers with your changes.

You can configure it like this:
```yaml
dns01RecursiveNameservers: "1.1.1.1:53,1.0.0.1:53,8.8.8.8:53,8.8.4.4:53"
```
As a bonus, I also included Google's DNS servers as well. They always are pretty quick to pickup changes as well

## Setup Dev and Prod Issuers with LetsEncrypt
Having both is helpful during the debugging process as it allows you to end-to-end create certificates and not run into issues with limits. By using LetsEncrypts dev endpoint, you can save yourself some debugging headache

## ArgoCD Needs to be setup with the --insecure flag if you want it to be public facing
ArgoCD has its own certificate to work with when you use the kubectl proxy. But if you want it to be public facing, you'll need to disable this functionality. Otherwise, you will end up with constant redirect loops

To have argocd run insecure, from Helm, configure the following in your `values.yaml`:
```yaml
server:
  extraArgs:
    - --insecure
```

Or wherever you run the ArgoCD container, make sure to pass the argument `--insecure` to the binary

## Terraform Kubernetes provider 'kubernetes_manifest' has a bug for cluster setup workflows
Youll need to use the kubectl provider instead, and specifically the fork created by `alekc` as the original provider also had its own bug and the project has not been regularly maintained by the owner anymore

## cert-manager has a bug in how its CRDs are installed

The deprecated 'installCRDS' variable is actually the only way to install the CRDs via helm. The replaced options of `crds.keep` and `crds.install` do not actually work

## Install your CRDS seperatly first

Not doing this is a pain in the ass when it comes to IaC and wanting to cross configure various tools within your cluster.

Example: 

When setting up cert-manager, you want to send metrics to Prometheus. In kubernetes you do this by enabling the following in your helm chart:
```yaml
prometheus:
  enabled: false
  servicemonitor:
    enabled: false
```
But none of these settings will work. Your deployment will actually crash because the ServiceMonitor CRD is not installed, which you need to install Prometheus for first

So why not setup Prometheus first ? This may work if you don't want to use TLS on the Prometheus dashboard. So you end with a loop where cert-manager needs to go first so that you can create your certs, but you need Prometheus first so that the CRDs are available to have monitoring available on your cert-manager.

This and other like situations happens a bunch once you start trying to setup your observability stack within your Kubernetes cluster. With trying to use IaC you quickly end up with many race conditions because of these overlapping dependencies on eachother to create a complete observability picture.

## ArgoCD _might_ need a project, before it will start sending _any_ metrics to prometheus
Prometheus will detect argocd, and the ServiceMonitors will be created. But you will have no observable metrics, and the ArgoCD official Grafana dashboard will show no data, if you have no project deployed yet. Even for metrics completely unrelated to the project (example: Redis, and the ArgoCD web server)

## kubectl_path_documents doesn't work inside modules or when depends_on is used
https://github.com/gavinbunney/terraform-provider-kubectl/issues/61
https://github.com/gavinbunney/terraform-provider-kubectl/issues/215

Fixed it by using terraform built in functions to replicate the functionality that kubectl_path_documents offered

## CRDs are a big deal in Kubernetes. Also how to manage them and apply them is a scattered mess right now
https://medium.com/pareture/kubectl-install-crd-failed-annotations-too-long-2ebc91b40c7d
https://github.com/kubernetes/kubernetes/issues/82292

Theres client issues in kubectl where many large project's CRDs are now hitting the file size limits that it will allow. So you need to use the `--server-side` parameter for these to work

Also kubernetes was not designed with any formal system in mind to upgrade and maintain these CRDs. There is the Operator Framework which has a system for managing versions and upgrades of CRDS, but then you can only install projects that are available on its operator hub, or those basically who support working with it

The selection there is a subset

## Kubernetes is still exceptionally new
The newness is causing a lot of inconcistencies on how deployments should work

There are Helm charts, that _some_ support. 

There are just raw manifest files as an installation method that _some_ support

There is the Operator Framework which is like a package manager but specifically just for the CRDS, that _some_ support

And then there are others who the only way you can use them is by compiling their Go code which uses some framework to generate all of the manifests

Then on the worst end of things (the operator framework, COUGH). When you want to install it, you have to locally install their CLI tool which then gives you the option to point it at your cluster to deploy it. There is NO other way to deploy this framework for some reason

The often problem too, is various products pick various ways of doing things. Helm or having some raw manifests somewhere are the often most popular choice that is available. But it is not 100% on all resources. And this makes an annoying developer experience that is hard to have a consisten workflow with

Oh not to mention, these days there is also an option where people are insisting on use ArgoCD's App-Of-Apps pattern which has some mass layering of Helm charts to work with Argo. Sometimes this is intended to be the primary way of installing the application

## Helm is a Design Flaw. It deviates away from Kubernetes design and architecture
CRDs are meant to be the powerhouse of Kubernetes. To make something Cloud/Kubernetes native. You create CRDs which are the building blocks to create and configure your application within the cluster.

Helm ignores this feature, and instead focuses on trying to template out all components. It leave this to working with the Kubernetes primitive, Pod/Service/Secrets services. Which are the basics, but aren't the full capabilities of the framework. They are really just the surface, and Helm encourage people away from those advanced and powerful capabilities with its workflows.

## Prometheus-Adapter has a bug in it, out the gate:
https://github.com/kubernetes-sigs/prometheus-adapter/issues/385

## S3 external storage documentation and secure configuration of keys is basically all out of date, scattered around, or broken! 
The grafana docs are complete shit. I've read it from multiple forums already, but this is my first experience where its truly shown its colors. In order to get proper cloud storage setup, i've had to jump between a bunch of forums, blind guess through a whole bunch of possibilities, and then stumble on a makeshift of a couple options in order to get everything working

Additionally, loki logging in its components won't give their additional debugging and help outputs if your S3 configuration is incorrect. So your stuck blind debugging until you get it mostly right!

Here is some of the places I looked that ended up completely wrong:
* https://github.com/grafana/loki/issues/12218
* https://github.com/grafana/loki/issues/8572
* https://community.grafana.com/t/provide-s3-credentials-using-environment-variables/100132/2

This one ended up being half right, but the format is out of date with the latest versions and helm charts
* https://akyriako.medium.com/kubernetes-logging-with-grafana-loki-promtail-in-under-10-minutes-d2847d526f9e

And this one, for digital ocean itself, was a complete mess of outdated information:
* https://www.digitalocean.com/community/developer-center/how-to-install-loki-stack-in-doks-cluster

And it was only some blind guessing around with this example on Grafana that I found something that accidently worked: https://grafana.com/docs/loki/latest/configure/storage/#aws-deployment-s3-single-store

Unfortunatly, I can't even really tell you why what I have works. But at the very least I can show you what did work for me


## Setting Up S3 / Digital Ocean Backed Storage with Loki and Securely Storing Access Keys

Im installing Loki via helm using the loki-distributed chart (because theres multiple of them and they seem to differ some even there in what they can and can not do). I am using version `0.79.0`

My `storageConfig` section was setup like this:
```yaml
  storageConfig:
    boltdb_shipper:
      shared_store: aws
      active_index_directory: /var/loki/index
      cache_location: /var/loki/cache
      cache_ttl: 1h
    filesystem:
      directory: /var/loki/chunks
# -- Uncomment to configure each storage individually
#   azure: {}
#   gcs: {}
    aws:
      s3: s3://${S3_LOKI_ACCESS_KEY}:${S3_LOKI_SECRET_ACCESS_KEY}@nyc3
      bucketnames: k8stack-resources
      endpoint: nyc3.digitaloceanspaces.com
      region: nyc3
      s3forcepathstyle: false
      insecure: false
      http_config:
        idle_conn_timeout: 90s
        response_header_timeout: 0s
        insecure_skip_verify: false
```
It seems like using `secretAccessKey` or `accessKeyId` does not resolve the variables that are in the environment. It only appears to work within the `s3` string. And that value is custom to this project too! This is not AWS s3 connection syntax from what I have experienced.

Being Digital Ocean, I had to be a bit of tinkering with the `endpoint` value. Fortunatly, the log output spelt that one out for me

A key piece I also had to do is go through this configuration and look for all the `shared_store` values, as these sometimes were set to `s3`. From the Grafana docs I read `s3` and `aws` is an alias. But I don't trust it. So I'd recommend changing those values to `aws`. I _think_ what is happening here is this `aws` value used elsewhere is being used to find the `aws` key listed under `storageConfig` so as to find the access credentials etc

I then configured my secrets within the `extraEnv` section for each component I was deploying:
```yaml
  extraEnvFrom:
    - secretRef:
        name: loki-s3-credentials
```
This is an opaque secret with the following data:
```
S3_LOKI_ACCESS_KEY : <my access key>
S3_LOKI_SECRET_ACCESS_KEY: <my secret access key>
```
Don't listen to some of the documentation talking about these values needing to be URL encoded. Pass them in as they are when you received them. Kubernetes will base64 encode them as always, but you don't need to do anything to them yourself. Copy, paste, and let kubernetes do the rest


## Debugging and Post Deployment Checks

Once things appear to have booted successfully for you I would check your S3 or Digital Ocean bucket. Loki should have filled it with some content. If you have no content, something has _definitly_ gone wrong without you knowing it. Loki doesn't seem to be very obvious or giving about any issues

Some helpful commands I used with `kubectl` were:
```bash
# Get an overview, are things running or rebooting and failing ?
kubectl get all -n loki

# Get details of a pod. This includes boot highlights, but also allows you to confirm what environment variables were passed to your container
kubectl describe pod <one of the loki pods> -n loki

# Finally, output the log output of the container. Again, this will be pretty useless until you have it mostly right!
kubectl logs <the compactor pod> -n loki --follow
```
These allowed me to deduce what the hell was going on

To get more verbose output, also pass these arguments in the `extraArgs` section of each of the components you are deploying:
```yaml
  extraArgs:
    - -config.expand-env=true # you NEED this in order for environment variables to work in your storageConfig
    - --log.level=debug
    - --print-config-stderr
```
Again, `--log.level=debug` and `--print-config-stderr` are pretty useless until you get your `aws.s3` configuration correct. You'll be stuck with generic errors until you get that sorted


## Bonus Garbage
Oh, also. A whole bunch of these docs talk about using boltdb_shipper. That thing is deprecated! (https://grafana.com/docs/loki/latest/configure/storage/#boltdb-deprecated) There is a new one (https://grafana.com/docs/loki/latest/configure/storage/#tsdb-recommended), but man...documentation ? Where is it ? Nobody appears to be using this yet either