################################################################################
# AWS EBS CSI Driver
# https://github.com/kubernetes-sigs/aws-ebs-csi-driver
################################################################################

# IAM Role for EBS CSI Driver (IRSA)
resource "aws_iam_role" "ebs_csi_driver_role" {
  name                 = "${var.cluster_name}-ebs-csi-driver-role"
  permissions_boundary = var.iam_role_permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.ebs_csi_driver_assume_role.json

  tags = local.common_tags
}

# Attach AWS managed policy for EBS CSI Driver
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_pa" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Helm Release for AWS EBS CSI Driver
resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = var.aws_ebs_csi_driver_version
  namespace  = local.kube_system_namespace

  values = [
    templatefile("${path.module}/yamls/aws-ebs-csi-driver-values.yaml", {
      role_arn = aws_iam_role.ebs_csi_driver_role.arn
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver_pa
  ]
}
