# AWS EBS CSI Driver

The Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver manages the lifecycle of Amazon EBS volumes for persistent volumes on your Kubernetes cluster.

## Configuration

The addon is deployed via Helm chart `aws-ebs-csi-driver`.

### Default Values

- **Version**: `2.33.0` (configurable via `aws_ebs_csi_driver_version`)
- **StorageClass**: `gp3` (default), with specific IOPS and throughput settings configurable in values.
- **IRSA**: A dedicated IAM role is created with the `AmazonEBSCSIDriverPolicy` managed policy.

### Customization

You can customize the Helm values by modifying [yamls/aws-ebs-csi-driver-values.yaml](../yamls/aws-ebs-csi-driver-values.yaml).

## Verification

Check if the pods are running:

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
```

Check the storage class:

```bash
kubectl get sc
```
