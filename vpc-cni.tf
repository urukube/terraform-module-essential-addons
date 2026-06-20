################################################################################
# AWS VPC CNI
# https://github.com/aws/amazon-vpc-cni-k8s/tree/master/charts/aws-vpc-cni
################################################################################

# IAM Role for VPC CNI (IRSA)
resource "aws_iam_role" "vpc_cni_role" {
  name                 = "${var.cluster_name}-vpc-cni-role"
  permissions_boundary = var.iam_role_permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.vpc_cni_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "vpc_cni_pa" {
  role       = aws_iam_role.vpc_cni_role.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"

}

# Helm Release for VPC CNI
resource "helm_release" "vpc_cni" {
  name       = "aws-vpc-cni"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-vpc-cni"
  version    = var.vpc_cni_version
  namespace  = local.kube_system_namespace

  values = [
    templatefile("${path.module}/yamls/vpc-cni-values.yaml", {
      region   = data.aws_region.current.name
      role_arn = aws_iam_role.vpc_cni_role.arn
    })
  ]

  depends_on = [aws_iam_role_policy_attachment.vpc_cni_pa]
}
