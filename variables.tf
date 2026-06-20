################ORG INFO##########################
variable "bu_id" {
  description = "Business Unit"
  type        = string
  default     = null
}

variable "app_id" {
  description = "application Unit"
  type        = string
  default     = null
}

variable "env" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = can(regex("^(dev|staging|prod|test)$", var.env))
    error_message = "Environment must be dev, staging, or prod"
  }
}

################CLUSTER INFO######################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster API server"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the cluster"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA (IAM Roles for Service Accounts)"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "URL of the OIDC issuer for the EKS cluster"
  type        = string
}

##################################################

################ADDON VERSIONS####################

variable "cluster_autoscaler_version" {
  description = "Version of the Cluster Autoscaler Helm chart"
  type        = string
  default     = "9.54.0"
}

variable "vpc_cni_version" {
  description = "Version of the AWS VPC CNI Helm chart"
  type        = string
  default     = "1.21.1"
}

variable "coredns_version" {
  description = "Version of the CoreDNS Helm chart"
  type        = string
  default     = "1.45.0"
}

variable "aws_lb_controller_version" {
  description = "Version of the AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.17.0"
}

variable "metrics_server_version" {
  description = "Version of the Metrics Server Helm chart"
  type        = string
  default     = "3.13.0"
}

variable "pod_identity_agent_version" {
  description = "Version of the EKS Pod Identity Agent addon"
  type        = string
  default     = null
}

variable "aws_ebs_csi_driver_version" {
  description = "Version of the AWS EBS CSI Driver Helm chart"
  type        = string
  default     = "2.33.0"
}

##################################################

################NETWORKING INFO###################

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}



# Cluster Service IP CIDR is a dynamic value we will receive after eks cluster creation
# This is required for coredns addon
# From the CIDR range we will calculate the 10th IP as cluster dns ip which will be assign
variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. (e.g. 10.100.0.0/16 or 172.20.0.0/16)"
  type        = string
  default     = "172.20.0.0/16"
}

##################################################

################COMMON CONFIG#####################

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the permissions boundary to attach to IAM roles"
  type        = string
  default     = null
}

##################################################
