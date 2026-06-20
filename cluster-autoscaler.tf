################################################################################
# Cluster Autoscaler
# https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler
################################################################################

# IAM Role for Cluster Autoscaler (IRSA)
resource "aws_iam_role" "cluster_autoscaler_role" {
  name                 = "${var.cluster_name}-cluster-autoscaler-role"
  permissions_boundary = var.iam_role_permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cluster_autoscaler_pa" {
  name   = "${var.cluster_name}-cluster-autoscaler-policy"
  role   = aws_iam_role.cluster_autoscaler_role.id
  policy = data.aws_iam_policy_document.cluster_autoscaler_policy_doc.json
}

# Helm Release for Cluster Autoscaler
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler_version
  namespace  = local.kube_system_namespace

  values = [
    templatefile("${path.module}/yamls/cluster-autoscaler-values.yaml", {
      cluster_name = var.cluster_name
      region       = data.aws_region.current.region
      role_arn     = aws_iam_role.cluster_autoscaler_role.arn
    })
  ]

  depends_on = [
    aws_iam_role_policy.cluster_autoscaler_pa,
    helm_release.vpc_cni
  ]
}
