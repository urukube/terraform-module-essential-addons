provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    host                   = "<cluster-endpoint>"
    cluster_ca_certificate = base64decode("dGVzdA==")

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", "<cluster-name>"]
    }
  }
}

provider "kubernetes" {
  host                   = "<cluster-endpoint>"
  cluster_ca_certificate = base64decode("dGVzdA==")

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "<cluster-name>"]
  }
}
