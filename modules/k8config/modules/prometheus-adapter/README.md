# prometheus-adapter Module
This module installs the prometheus-adapter project into the cluster under the `prometheus-adapter` namespace. This adapter replaces the metrics-server (https://github.com/kubernetes-sigs/metrics-server) which is most popularly used in kubernetes clusters. The reason `prometheus-adapter` is being used instead is because we already have prometheus installed. See the prometheus module for details on that component.

By using `prometheus-adapter` we can use prometheus to query the metrics that are already being collected by it, and supply that to the Kubernetes Metrics API, instead of having to collect them ourselves

# Usage
The primary usage of this module is to provide the Metrics API with metrics. You can access these metrics with `kubectl`. The purpose is to be able to quickly get a view of CPU and Memory usage of Nodes and Pods from the kubectl command line

## Top CPU and Memory Consuming Pods
Run the following command to view an ordered list of the top consuming pods 
```bash
kubectl top pod --all-namespaces
```

## Top CPU and Memory Consuming Nodes
Run thie following command to view a list of the top consuming nodes
```bash
kubectl top node --all-namespaces
```

# Resources

Helm Chart: https://artifacthub.io/packages/helm/prometheus-community/prometheus-adapter
Configuration Related Issues and Help: https://github.com/prometheus-community/helm-charts/issues/1974

prometheus-adapter has a bug in it out the gate: https://github.com/kubernetes-sigs/prometheus-adapter/issues/385
