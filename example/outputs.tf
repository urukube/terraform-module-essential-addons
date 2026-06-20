output "cluster_autoscaler_iam_role_arn" {
  description = "ARN of the IAM role for Cluster Autoscaler"
  value       = module.essential_addons.cluster_autoscaler_iam_role_arn
}

output "aws_lb_controller_iam_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = module.essential_addons.aws_lb_controller_iam_role_arn
}
