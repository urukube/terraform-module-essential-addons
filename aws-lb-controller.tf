################################################################################
# AWS Load Balancer Controller
# https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
################################################################################

# IAM Role for AWS Load Balancer Controller (IRSA)
resource "aws_iam_role" "aws_lb_controller_role" {
  name                 = "${var.cluster_name}-aws-lb-controller-role"
  permissions_boundary = var.iam_role_permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.aws_lb_controller_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "aws_lb_controller_pa" {
  name   = "${var.cluster_name}-aws-lb-controller-policy"
  role   = aws_iam_role.aws_lb_controller_role.id
  policy = data.aws_iam_policy_document.aws_lb_controller.json
}

# Helm Release for AWS Load Balancer Controller
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_lb_controller_version
  namespace  = local.kube_system_namespace

  values = [
    templatefile("${path.module}/yamls/aws-lb-controller-values.yaml", {
      cluster_name = var.cluster_name
      region       = data.aws_region.current.region
      vpc_id       = var.vpc_id
      role_arn     = aws_iam_role.aws_lb_controller_role.arn
    })
  ]

  depends_on = [
    aws_iam_role_policy.aws_lb_controller_pa,
    helm_release.vpc_cni
  ]
}
