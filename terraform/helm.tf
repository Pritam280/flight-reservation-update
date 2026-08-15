
provider "helm" {

  kubernetes {

    host = data.aws_eks_cluster.flight.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.flight.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.flight.token
  }
}

provider "kubernetes" {

  host = data.aws_eks_cluster.flight.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.flight.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.flight.token

}


resource "kubernetes_service_account" "alb_controller" {

  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn

    }
  }
   depends_on = [
    aws_eks_cluster.flight_cluster
  ]

}

resource "helm_release" "aws_load_balancer_controller" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"

  create_namespace = false

  set {
    name  = "clusterName"
    value = aws_eks_cluster.flight_cluster.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }

    depends_on = [
    aws_eks_cluster.flight_cluster,
    aws_eks_node_group.flight_node_group,
    kubernetes_service_account.alb_controller
    ]
  set {
  name  = "region"
  value = "us-east-1"
  }

  set {
  name  = "vpcId"
  value = aws_vpc.main.id
  }
}
