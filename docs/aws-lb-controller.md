# Why do we need AWS Load Balancer Controller?

The AWS Load Balancer Controller manages AWS Elastic Load Balancers (ALB) and Network Load Balancers (NLB) for a Kubernetes cluster. It satisfies Kubernetes `Ingress` resources by provisioning Application Load Balancers and `Service` resources of type `LoadBalancer` by provisioning Network Load Balancers.

In order to create the AWS Load Balancer Controller, below is the order of operation:

IAM Role -> Policy Attachment -> Helm Release

## Step 1: IAM Role Creation (aws_iam_role.aws_lb_controller_role):

- Creates the IAM role `${var.cluster_name}-aws-lb-controller-role` with the OIDC trust relationship policy.
- This is the foundation for IRSA (IAM Roles for Service Accounts).

## Step 2: IAM Policy Attachment (aws_iam_role_policy.aws_lb_controller_pa):

- Attaches the comprehensive IAM policy (defined in `data.aws_iam_policy_document.aws_lb_controller`) to the role created in step 1.
- This policy grants permissions to manage ELBs, EC2 targets, Security Groups, etc.
- Implicit Dependency: Requires `aws_iam_role.aws_lb_controller_role`.

## Step 3: Helm Release (helm_release.aws_lb_controller):

- Deploy/Upgrade the `aws-load-balancer-controller` helm chart.
- Explicit Dependency: `depends_on = [aws_iam_role_policy.aws_lb_controller_pa]`.
- This ensures the helm chart only runs **AFTER** the permissions are fully properly attached to the IAM role.
- It configures the Service Account to be created (`create = true`) and annotates it with the IAM Role ARN.

## Load Balancer Types & Use Cases

| Type                                | K8s Resource                    | Layer                | Use Cases                                                                                                                                                                                                                                                             | Key Annotations                                                                                                                                                                                  |
| :---------------------------------- | :------------------------------ | :------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Application Load Balancer (ALB)** | `Ingress`                       | Layer 7 (HTTP/HTTPS) | • **HTTP/HTTPS Routing**: Path-based or Host-based routing.<br>• **SSL Termination**: Offloading SSL/TLS at the load balancer.<br>• **WAF Integration**: Protecting apps with AWS WAF.<br>• **Cognito Auth**: Authenticating users via Cognito before accessing apps. | `alb.ingress.kubernetes.io/scheme`<br>`alb.ingress.kubernetes.io/certificate-arn`<br>`alb.ingress.kubernetes.io/listen-ports`<br>`alb.ingress.kubernetes.io/group.name`                          |
| **Network Load Balancer (NLB)**     | `Service` (type `LoadBalancer`) | Layer 4 (TCP/UDP)    | • **High Performance**: Extremely low latency/high throughput.<br>• **Non-HTTP Protocols**: Direct TCP/UDP traffic.<br>• **Static IP**: Exposing services on static Elastic IPs.<br>• **PrivateLink**: Exposing services to other VPCs privately.                     | `service.beta.kubernetes.io/aws-load-balancer-type: "external"`<br>`service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"`<br>`service.beta.kubernetes.io/aws-load-balancer-scheme` |
