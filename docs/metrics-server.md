# Why do we need Metrics Server?

Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines. It collects resource metrics (CPU and memory) from kubelets and exposes them via the Kubernetes Metrics API.

Key responsibilities:
- **Horizontal Pod Autoscaler (HPA)**: Provides CPU/memory metrics required for HPA to scale workloads.
- **Vertical Pod Autoscaler (VPA)**: Supplies metrics for VPA recommendations.
- **kubectl top**: Enables `kubectl top nodes` and `kubectl top pods` commands.
- **Kubernetes Dashboard**: Provides metrics for dashboard resource views.

In order to create Metrics Server, below is the order of operation:

Helm Release (single step - no IAM required)

## Step 1: Helm Release (helm_release.metrics_server):

- Deploy/Upgrade the `metrics-server` helm chart from `https://kubernetes-sigs.github.io/metrics-server/`.
- **No IAM Role Required**: Metrics Server only needs in-cluster permissions (RBAC) to read kubelet metrics, not AWS API access.
- **Deployment Configuration**: Runs with 2 replicas for high availability.

## Metrics Server Configuration Highlights

| Configuration | Value | Purpose |
|:--------------|:------|:--------|
| **Replicas** | 2 | High availability |
| **Metric Resolution** | 15s | How often metrics are scraped |
| **Kubelet Address Type** | InternalIP | Use node internal IPs for communication |

## Key Arguments

```yaml
args:
  - "--kubelet-preferred-address-types=InternalIP"  # Use internal IPs to reach kubelets
  - "--kubelet-use-node-status-port"                 # Use the port from node status
  - "--metric-resolution=15s"                        # Scrape interval
```

## Usage Examples

Once deployed, you can use:

```bash
# View node resource usage
kubectl top nodes

# View pod resource usage
kubectl top pods -A

# HPA will automatically use metrics for scaling decisions
kubectl autoscale deployment my-app --cpu-percent=50 --min=1 --max=10
```
