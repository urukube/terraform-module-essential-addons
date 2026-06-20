# EKS Cluster Essential Addons

- Terraform module for deploying essential EKS addons using official Helm releases and AWS EKS addons. All addons are mandatory and deployed together. Please note that this module needs to be run after the eks-infra has been deployed.

- Please check the [orchestrator-plane-setup](https://github.com/urukube/orchestrator-plane-setup) for more details. You will see that, in this repository, we are calling this module after the eks-infra has been deployed.

## Addons Included

| Addon                            | Description                                              | Deployment Method | Readme                               |
| -------------------------------- | -------------------------------------------------------- | ----------------- | ------------------------------------ |
| **Cluster Autoscaler**           | Auto-scales node groups based on pending pods            | Helm              | [Readme](docs/cluster-autoscaler.md) |
| **VPC CNI**                      | AWS-native CNI for pod networking with prefix delegation | Helm              | [Readme](docs/vpc-cni.md)            |
| **CoreDNS**                      | Kubernetes DNS service                                   | Helm              | [Readme](docs/coredns.md)            |
| **AWS Load Balancer Controller** | Manages ALB/NLB for Kubernetes services                  | Helm              | [Readme](docs/aws-lb-controller.md)  |
| **Metrics Server**               | Resource metrics for HPA/VPA                             | Helm              | [Readme](docs/metrics-server.md)     |
| **AWS EBS CSI Driver**           | Manages EBS volumes for PersistentVolumes                | Helm              | [Readme](docs/aws-ebs-csi-driver.md) |
| **EKS Pod Identity Agent**       | Simplified IAM permissions for pods                      | EKS Addon         | [Readme](docs/pod-identity-agent.md) |

## Prerequisites

- Existing EKS cluster with OIDC provider enabled
- Terraform >= 1.5.0
- AWS Provider >= 6.42.0
- Helm Provider >= 2.16.0
- Kubernetes Provider >= 2.35.0

## Usage

```hcl
module "essential_addons" {
  source = "git::https://github.com/urukube/terraform-module-essential-addons.git?ref=v1.0.0"

  # Cluster connection
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_oidc_provider_arn          = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url            = module.eks.oidc_issuer_url

  # Networking
  vpc_id = module.networking.vpc_id

  # Optional: Version overrides
  # cluster_autoscaler_version = "9.43.2"
  # vpc_cni_version            = "1.19.0"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Provider Configuration

The calling module must configure the Helm and Kubernetes providers:

```hcl
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
```

## Inputs

| Name                               | Description                                | Type          | Default | Required |
| ---------------------------------- | ------------------------------------------ | ------------- | ------- | :------: |
| cluster_name                       | Name of the EKS cluster                    | `string`      | n/a     |   yes    |
| cluster_endpoint                   | Endpoint URL of the EKS cluster API server | `string`      | n/a     |   yes    |
| cluster_certificate_authority_data | Base64 encoded certificate authority data  | `string`      | n/a     |   yes    |
| cluster_oidc_provider_arn          | ARN of the OIDC provider for IRSA          | `string`      | n/a     |   yes    |
| cluster_oidc_issuer_url            | URL of the OIDC issuer                     | `string`      | n/a     |   yes    |
| vpc_id                             | VPC ID where the EKS cluster is deployed   | `string`      | n/a     |   yes    |
| tags                               | Tags to apply to all resources             | `map(string)` | `{}`    |    no    |
| iam_role_permissions_boundary      | ARN of permissions boundary for IAM roles  | `string`      | `null`  |    no    |

## Outputs

| Name                             | Description                                 |
| -------------------------------- | ------------------------------------------- |
| cluster_autoscaler_iam_role_arn  | ARN of the Cluster Autoscaler IAM role      |
| vpc_cni_iam_role_arn             | ARN of the VPC CNI IAM role                 |
| aws_lb_controller_iam_role_arn   | ARN of the AWS LB Controller IAM role       |
| cluster_autoscaler_release_name  | Name of the Cluster Autoscaler Helm release |
| vpc_cni_release_name             | Name of the VPC CNI Helm release            |
| coredns_release_name             | Name of the CoreDNS Helm release            |
| aws_lb_controller_release_name   | Name of the AWS LB Controller Helm release  |
| metrics_server_release_name      | Name of the Metrics Server Helm release     |
| pod_identity_agent_addon_version | Version of the Pod Identity Agent addon     |

## IRSA (IAM Roles for Service Accounts)

This module automatically creates IRSA roles for addons that require AWS API access:

- **Cluster Autoscaler**: Permissions to manage Auto Scaling Groups
- **VPC CNI**: AmazonEKS_CNI_Policy
- **AWS Load Balancer Controller**: Comprehensive ELB/EC2 permissions

## License

Apache 2.0 License

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.16.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.42.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.pod_identity_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_role.aws_lb_controller_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cluster_autoscaler_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ebs_csi_driver_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_cni_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.aws_lb_controller_pa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cluster_autoscaler_pa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ebs_csi_driver_pa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc_cni_pa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_lb_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.coredns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.vpc_cni](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.aws_lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.aws_lb_controller_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_autoscaler_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_autoscaler_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ebs_csi_driver_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_cni_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | application Unit | `string` | `null` | no |
| <a name="input_aws_ebs_csi_driver_version"></a> [aws\_ebs\_csi\_driver\_version](#input\_aws\_ebs\_csi\_driver\_version) | Version of the AWS EBS CSI Driver Helm chart | `string` | `"2.33.0"` | no |
| <a name="input_aws_lb_controller_version"></a> [aws\_lb\_controller\_version](#input\_aws\_lb\_controller\_version) | Version of the AWS Load Balancer Controller Helm chart | `string` | `"1.17.0"` | no |
| <a name="input_bu_id"></a> [bu\_id](#input\_bu\_id) | Business Unit | `string` | `null` | no |
| <a name="input_cluster_autoscaler_version"></a> [cluster\_autoscaler\_version](#input\_cluster\_autoscaler\_version) | Version of the Cluster Autoscaler Helm chart | `string` | `"9.54.0"` | no |
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | Base64 encoded certificate authority data for the cluster | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Endpoint URL of the EKS cluster API server | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#input\_cluster\_oidc\_issuer\_url) | URL of the OIDC issuer for the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_oidc_provider_arn"></a> [cluster\_oidc\_provider\_arn](#input\_cluster\_oidc\_provider\_arn) | ARN of the OIDC provider for IRSA (IAM Roles for Service Accounts) | `string` | n/a | yes |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | The CIDR block to assign Kubernetes service IP addresses from. (e.g. 10.100.0.0/16 or 172.20.0.0/16) | `string` | `"172.20.0.0/16"` | no |
| <a name="input_coredns_version"></a> [coredns\_version](#input\_coredns\_version) | Version of the CoreDNS Helm chart | `string` | `"1.45.0"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the permissions boundary to attach to IAM roles | `string` | `null` | no |
| <a name="input_metrics_server_version"></a> [metrics\_server\_version](#input\_metrics\_server\_version) | Version of the Metrics Server Helm chart | `string` | `"3.13.0"` | no |
| <a name="input_pod_identity_agent_version"></a> [pod\_identity\_agent\_version](#input\_pod\_identity\_agent\_version) | Version of the EKS Pod Identity Agent addon | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cni_version"></a> [vpc\_cni\_version](#input\_vpc\_cni\_version) | Version of the AWS VPC CNI Helm chart | `string` | `"1.21.1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the EKS cluster is deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_lb_controller_iam_role_arn"></a> [aws\_lb\_controller\_iam\_role\_arn](#output\_aws\_lb\_controller\_iam\_role\_arn) | ARN of the IAM role for AWS Load Balancer Controller |
| <a name="output_aws_lb_controller_release_name"></a> [aws\_lb\_controller\_release\_name](#output\_aws\_lb\_controller\_release\_name) | Name of the AWS Load Balancer Controller Helm release |
| <a name="output_cluster_autoscaler_iam_role_arn"></a> [cluster\_autoscaler\_iam\_role\_arn](#output\_cluster\_autoscaler\_iam\_role\_arn) | ARN of the IAM role for Cluster Autoscaler |
| <a name="output_cluster_autoscaler_release_name"></a> [cluster\_autoscaler\_release\_name](#output\_cluster\_autoscaler\_release\_name) | Name of the Cluster Autoscaler Helm release |
| <a name="output_coredns_release_name"></a> [coredns\_release\_name](#output\_coredns\_release\_name) | Name of the CoreDNS Helm release |
| <a name="output_metrics_server_release_name"></a> [metrics\_server\_release\_name](#output\_metrics\_server\_release\_name) | Name of the Metrics Server Helm release |
| <a name="output_pod_identity_agent_addon_version"></a> [pod\_identity\_agent\_addon\_version](#output\_pod\_identity\_agent\_addon\_version) | Version of the EKS Pod Identity Agent addon |
| <a name="output_vpc_cni_iam_role_arn"></a> [vpc\_cni\_iam\_role\_arn](#output\_vpc\_cni\_iam\_role\_arn) | ARN of the IAM role for VPC CNI |
| <a name="output_vpc_cni_release_name"></a> [vpc\_cni\_release\_name](#output\_vpc\_cni\_release\_name) | Name of the VPC CNI Helm release |
<!-- END_TF_DOCS -->
