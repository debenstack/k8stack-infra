# Recommendations

This is a doc outlining things to consider when setting up your own kubernetes cluster. Things that should be evaluated to have an effecting scaling and operation of Kubernetes

# How Are People Connecting To Your Cluster ?
LoadBalancers are easier, but they cost more per. Ingress Controller is more complicated BUT it only uses one LoadBalancer

# Install your CRDS First
Interdependencies between your applications will make this easier

# Version Lock Everything
You don't want your CRDs or application upgrading at a random time from a random deploy. CRD and Operator misalignment is a pain in the ass to debug as there is generally no logs from the application, and nothing but vague output from Kubernetes

# Setup All Your Metrics Monitoring Services And Then Put In Resource.Limits and Resource.Requests parameters
These metrics are how Kubernetes will assign your resources. If they are not defined, kubernetes will dump them just anywhere. 

Also, you can't really determine what a pod needs until its running. So you'll want to setup either metrics-server or prometheus-adapter or some way to monitor CPU and Memory usage of your Pod so you can determine how much it needs, and how much it should _not_ need.

Without these values, Kubernetes is pretty ineffective at scaling and optimising your cluster resources

