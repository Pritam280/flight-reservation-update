data "aws_eks_cluster" "flight" {
  name = aws_eks_cluster.flight_cluster.name
}

data "aws_eks_cluster_auth" "flight" {
  name = aws_eks_cluster.flight_cluster.name
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.flight.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {

  url = data.aws_eks_cluster.flight.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name = "flight-eks-oidc"
  }
}
