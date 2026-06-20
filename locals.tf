
data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  partition = data.aws_partition.current.partition

  # Extract OIDC issuer ID from the URL
  oidc_issuer_id = replace(var.cluster_oidc_issuer_url, "https://", "")

  # Common labels for Helm releases
  common_labels = merge(var.tags, {
    "app.kubernetes.io/managed-by" = "terraform"
    "cluster"                      = var.cluster_name
  })

  # Namespace for kube-system addons
  kube_system_namespace = "kube-system"

  common_tags = merge(
    var.tags,
    {
      bu_id  = var.bu_id
      app_id = var.app_id
      env    = var.env
    }
  )

  # Calculate CoreDNS ClusterIP (10th IP in the Service CIDR)
  cluster_dns_ip = cidrhost(var.cluster_service_ipv4_cidr, 10)
}
