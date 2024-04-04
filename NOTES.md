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