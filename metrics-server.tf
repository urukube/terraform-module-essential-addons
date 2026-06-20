################################################################################
# Metrics Server
# https://github.com/kubernetes-sigs/metrics-server/tree/master/charts/metrics-server
################################################################################

# Helm Release for Metrics Server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_version
  namespace  = local.kube_system_namespace

  values = [
    file("${path.module}/yamls/metrics-server-values.yaml")
  ]

  depends_on = [helm_release.vpc_cni]
}
