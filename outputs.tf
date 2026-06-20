################################################################################
# Cluster Autoscaler Outputs
################################################################################

output "cluster_autoscaler_iam_role_arn" {
  description = "ARN of the IAM role for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler_role.arn
}

output "cluster_autoscaler_release_name" {
  description = "Name of the Cluster Autoscaler Helm release"
  value       = helm_release.cluster_autoscaler.name
}

################################################################################
# VPC CNI Outputs
################################################################################

output "vpc_cni_iam_role_arn" {
  description = "ARN of the IAM role for VPC CNI"
  value       = aws_iam_role.vpc_cni_role.arn
}

output "vpc_cni_release_name" {
  description = "Name of the VPC CNI Helm release"
  value       = helm_release.vpc_cni.name
}

################################################################################
# CoreDNS Outputs
################################################################################

output "coredns_release_name" {
  description = "Name of the CoreDNS Helm release"
  value       = helm_release.coredns.name
}

################################################################################
# AWS Load Balancer Controller Outputs
################################################################################

output "aws_lb_controller_iam_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_lb_controller_role.arn
}

output "aws_lb_controller_release_name" {
  description = "Name of the AWS Load Balancer Controller Helm release"
  value       = helm_release.aws_lb_controller.name
}

################################################################################
# Metrics Server Outputs
################################################################################

output "metrics_server_release_name" {
  description = "Name of the Metrics Server Helm release"
  value       = helm_release.metrics_server.name
}

################################################################################
# Pod Identity Agent Outputs
################################################################################

output "pod_identity_agent_addon_version" {
  description = "Version of the EKS Pod Identity Agent addon"
  value       = aws_eks_addon.pod_identity_agent.addon_version
}
