# Why do we need Cluster Autoscaler?

The Kubernetes Cluster Autoscaler automatically adjusts the size of the Kubernetes cluster when one of the following conditions is true:

- There are pods that failed to run in the cluster due to insufficient resources.
- There are nodes in the cluster that have been underutilized for an extended period of time and their pods can be placed on other existing nodes.

In order to create the Cluster Autoscaler, below is the order of operation:

IAM Role -> Policy Attachment -> Helm Release

## Step 1: IAM Role Creation (aws_iam_role.cluster_autoscaler_role):

- Creates the IAM role `${var.cluster_name}-cluster-autoscaler-role` with the OIDC trust relationship policy.
- This is the foundation for IRSA (IAM Roles for Service Accounts).

## Step 2: IAM Policy Attachment (aws_iam_role_policy.cluster_autoscaler_pa):

- Attaches the custom IAM policy (defined in `data.aws_iam_policy_document.cluster_autoscaler_policy_doc`) to the role created in step 1.
- This policy grants permissions to describe and update Auto Scaling Groups (ASGs).
- Implicit Dependency: Requires `aws_iam_role.cluster_autoscaler_role`.

## Step 3: Helm Release (helm_release.cluster_autoscaler):

- Deploy/Upgrade the `cluster-autoscaler` helm chart.
- Explicit Dependency: `depends_on = [aws_iam_role_policy.cluster_autoscaler_pa]`.
- This ensures the helm chart only runs **AFTER** the permissions are fully properly attached to the IAM role.
- It configures the Service Account to be created (`create = true`) and annotates it with the IAM Role ARN.
