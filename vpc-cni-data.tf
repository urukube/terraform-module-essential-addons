################################################################################
# VPC CNI IAM Policy Documents
################################################################################

data "aws_iam_policy_document" "vpc_cni_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.cluster_oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_id}:sub"
      values   = ["system:serviceaccount:${local.kube_system_namespace}:aws-node"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_id}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
