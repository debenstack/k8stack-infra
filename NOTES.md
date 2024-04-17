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

# The Traefik Dashboard Can Be Fully Secured With Basic Auth + Certificates From cert-manager Within its Helm Chart
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

# Setup DNS01 validation with non-wildcard domains and sub-domains using cert-manager and CloudFlare
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

# Setup Dev and Prod Issuers with LetsEncrypt
Having both is helpful during the debugging process as it allows you to end-to-end create certificates and not run into issues with limits. By using LetsEncrypts dev endpoint, you can save yourself some debugging headache

# ArgoCD Needs to be setup with the --insecure flag if you want it to be public facing
ArgoCD has its own certificate to work with when you use the kubectl proxy. But if you want it to be public facing, you'll need to disable this functionality. Otherwise, you will end up with constant redirect loops

To have argocd run insecure, from Helm, configure the following in your `values.yaml`:
```yaml
server:
  extraArgs:
    - --insecure
```

Or wherever you run the ArgoCD container, make sure to pass the argument `--insecure` to the binary

# Terraform Kubernetes provider 'kubernetes_manifest' has a bug for cluster setup workflows
Youll need to use the kubectl provider instead, and specifically the fork created by `alekc` as the original provider also had its own bug and the project has not been regularly maintained by the owner anymore

# cert-manager has a bug in how its CRDs are installed

The deprecated 'installCRDS' variable is actually the only way to install the CRDs via helm. The replaced options of `crds.keep` and `crds.install` do not actually work

# Install your CRDS seperatly first

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