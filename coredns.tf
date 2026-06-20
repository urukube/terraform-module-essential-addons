################################################################################
# CoreDNS
# https://github.com/coredns/helm
################################################################################

# Helm Release for CoreDNS
resource "helm_release" "coredns" {
  name       = "coredns"
  repository = "https://coredns.github.io/helm"
  chart      = "coredns"
  version    = var.coredns_version
  namespace  = local.kube_system_namespace

  values = [
    templatefile("${path.module}/yamls/coredns-values.yaml", {
      cluster_dns_ip = local.cluster_dns_ip
    })
  ]

  depends_on = [helm_release.vpc_cni]
}
