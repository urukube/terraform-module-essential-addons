# Why do we need EKS Pod Identity Agent?

EKS Pod Identity Agent is the next-generation solution for granting AWS IAM permissions to Kubernetes pods. It simplifies IAM Roles for Service Accounts (IRSA) by eliminating the need for OIDC provider configuration and complex trust policies.

Key benefits over traditional IRSA:
- **Simplified Setup**: No need to create and manage OIDC trust policies for each role.
- **Cluster-Scoped Associations**: Manage pod-to-role mappings at the cluster level.
- **Improved Security**: Uses short-lived credentials with automatic rotation.
- **Better Auditing**: CloudTrail logs show both the IAM role and the Kubernetes identity.

In order to create EKS Pod Identity Agent, below is the order of operation:

EKS Addon (single step - managed by AWS)

## Step 1: EKS Addon (aws_eks_addon.pod_identity_agent):

- Installs the `eks-pod-identity-agent` as an AWS-managed EKS addon.
- **No Custom IAM Role Required**: The addon itself uses AWS-managed permissions.
- **DaemonSet Deployment**: Runs on every node to intercept credential requests from pods.
- **Conflict Resolution**: Configured to `OVERWRITE` existing resources on create/update.

## Pod Identity vs IRSA Comparison

| Feature | Pod Identity | IRSA (Traditional) |
|:--------|:-------------|:-------------------|
| **OIDC Provider** | Not required | Required |
| **Trust Policy** | Managed by AWS | Manual per-role |
| **Setup Complexity** | Simple | Complex |
| **Credential Rotation** | Automatic | Automatic |
| **CloudTrail Audit** | Shows K8s identity | Shows role only |

## How It Works

```
Pod Request -> Pod Identity Agent (DaemonSet) -> AWS STS -> Temporary Credentials
```

1. Pod makes AWS API call
2. Pod Identity Agent intercepts the request
3. Agent exchanges pod identity for AWS credentials via STS
4. Credentials returned to the pod

## Usage

After installing the addon, create Pod Identity Associations:

```hcl
resource "aws_eks_pod_identity_association" "example" {
  cluster_name    = var.cluster_name
  namespace       = "my-namespace"
  service_account = "my-service-account"
  role_arn        = aws_iam_role.my_role.arn
}
```
