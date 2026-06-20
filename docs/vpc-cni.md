# Why do we need VPC CNI?

VPC CNI is a native CNI plugin for Kubernetes that provides pod networking with prefix delegation. It is a mandatory addon for EKS clusters and is required for pod networking. Even though pods are in different subnets due to worker nodes being in different AZs, VPC CNI provides a single overlay network for all pods.

In order to install VPC CNI, we need to install aws-node daemonset. aws-node daemonset is a mandatory addon for EKS clusters and is required for pod networking. In our case, we are using `aws-node` helm chart to install aws-node daemonset.

In order to create VPC CNI, below is the order of operation:

IAM Role -> (Policy Attachment & SA Annotation) -> Helm Release

## Step 1: IAM Role Creation (aws_iam_role.vpc_cni_role):

- Creates the IAM role ${var.cluster_name}-vpc-cni-role with the OIDC trust relationship policy.
- This is the foundation for IRSA (IAM Roles for Service Accounts).

## Step 2: IAM Policy Attachment (aws_iam_role_policy_attachment.vpc_cni_pa):

- Attaches the managed policy AmazonEKS_CNI_Policy to the role created in step 1.
- Implicit Dependency: Requires aws_iam_role.vpc_cni_role.

## Step 3: Service Account Annotation (kubernetes_annotations.vpc_cni_sa):

- Annotates the existing aws-node service account (which comes pre-installed on EKS) with the new IAM Role ARN.
- Explicit Dependency: depends_on = [aws_iam_role.vpc_cni_role].
- Note: This runs in parallel or slightly overlapping with step 2 (as both depend on the Role), but effectively ensures the SA is ready to use the role.

## Step 4: Helm Release (helm_release.vpc_cni):

- Deploy/Upgrade the aws-vpc-cni helm chart.
- Explicit Dependency: depends_on = [aws_iam_role_policy_attachment.vpc_cni_pa].
- This ensures the helm chart (which restarts/updates the aws-node pods) only runs AFTER the permissions are fully properly attached to the IAM role.
- It configures the DaemonSet to use the existing service account (create = false, name = "aws-node") which we annotated in step 3.
