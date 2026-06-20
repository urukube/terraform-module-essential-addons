
run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "plan" {
  command = plan

  variables {
    cluster_name                       = run.setup.cluster_name
    cluster_endpoint                   = run.setup.cluster_endpoint
    cluster_certificate_authority_data = run.setup.cluster_certificate_authority_data
    cluster_oidc_provider_arn          = run.setup.cluster_oidc_provider_arn
    cluster_oidc_issuer_url            = run.setup.cluster_oidc_issuer_url
    vpc_id                             = run.setup.vpc_id

    bu_id  = run.setup.bu_id
    app_id = run.setup.app_id
    env    = run.setup.env
  }

  # Verify Cluster Autoscaler IAM role is created
  assert {
    condition     = aws_iam_role.cluster_autoscaler_role.name == "test-cluster-cluster-autoscaler-role"
    error_message = "Cluster Autoscaler IAM role name did not match expected value"
  }

  # Verify VPC CNI IAM role is created
  assert {
    condition     = aws_iam_role.vpc_cni_role.name == "test-cluster-vpc-cni-role"
    error_message = "VPC CNI IAM role name did not match expected value"
  }

  # Verify AWS LB Controller IAM role is created
  assert {
    condition     = aws_iam_role.aws_lb_controller_role.name == "test-cluster-aws-lb-controller-role"
    error_message = "AWS LB Controller IAM role name did not match expected value"
  }
}
