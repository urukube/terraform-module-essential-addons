################################################################################
# Essential Addons Module - Example Usage
################################################################################

module "essential_addons" {
  source = "../"

  # Cluster connection
  cluster_name                       = "<cluster-name>"      # Replace with your cluster name
  cluster_endpoint                   = "<cluster-endpoint>"  # Replace with cluster endpoint
  cluster_certificate_authority_data = "<ca-data>"           # Replace with CA data
  cluster_oidc_provider_arn          = "<oidc-provider-arn>" # Replace with OIDC provider ARN
  cluster_oidc_issuer_url            = "<oidc-issuer-url>"   # Replace with OIDC issuer URL

  # Organization Info
  bu_id  = "example-bu"
  app_id = "example-app"
  env    = "dev"

  # Networking
  vpc_id = "<vpc-id>" # Replace with VPC ID
  region = "us-east-1"

  # Optional Networking
  cluster_service_ipv4_cidr = "172.20.0.0/16" # Default if not specified

  # IAM
  iam_role_permissions_boundary = null

  tags = local.tags
}
