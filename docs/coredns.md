# Why do we need CoreDNS?

CoreDNS is a flexible, extensible DNS server that serves as the cluster DNS for Kubernetes. It is responsible for resolving DNS queries within the cluster, enabling service discovery between pods and services.

Key responsibilities:
- **Service Discovery**: Resolves Kubernetes service names to their ClusterIP addresses (e.g., `my-service.my-namespace.svc.cluster.local`).
- **Pod DNS Resolution**: Provides DNS records for pods.
- **External DNS**: Forwards external DNS queries to upstream resolvers.

In order to create CoreDNS, below is the order of operation:

Helm Release (single step - no IAM required)

## Step 1: Helm Release (helm_release.coredns):

- Deploy/Upgrade the `coredns` helm chart from `https://coredns.github.io/helm`.
- **No IAM Role Required**: CoreDNS only needs in-cluster permissions (RBAC), not AWS API access.
- **ClusterIP Configuration**: The service is assigned a specific ClusterIP (`local.cluster_dns_ip`) calculated as the 10th IP in the cluster service CIDR range.
- **Deployment Configuration**: Runs with 2 replicas for high availability.

## CoreDNS Configuration Highlights

| Configuration | Value | Purpose |
|:--------------|:------|:--------|
| **ClusterIP** | `local.cluster_dns_ip` (10th IP in service CIDR) | Fixed DNS IP that kubelets use |
| **Replicas** | 2 | High availability |
| **Port** | 53 (TCP/UDP) | Standard DNS port |

## DNS Resolution Flow

```
Pod -> CoreDNS (ClusterIP) -> Service Resolution -> Target Pod/External DNS
```

CoreDNS uses the following plugins:
- `kubernetes`: Resolves cluster-internal DNS queries
- `forward`: Forwards external queries to upstream DNS (e.g., VPC DNS)
- `cache`: Caches DNS responses for performance
- `health`/`ready`: Health check endpoints
