
# IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
    name = "eks-cluster-role-1"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            }
        ]
    })
    tags = {
        Name = "flight-eks-cluster-role"
}
  
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}


# Iam role for node group

resource "aws_iam_role" "eks_node_role" {
    name = "eks-node-role-1"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            }
        ]
    })
    tags = {
         Name = "flight-eks-node-role"
        }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
    role = aws_iam_role.eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    role = aws_iam_role.eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_container_policy" {
    role = aws_iam_role.eks_node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


#IAM policy for Application load balancer controller

resource "aws_iam_policy" "alb_controller" {
    name = "AwsLBControllerPolicy"
    description = "IAM policy for ALB controller"

    policy = file("${path.module}/policies/alb-iam-policy.json")
}
data "aws_iam_policy_document" "alb_controller_assume_role" {

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {
      test = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.flight.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }

    condition {
      test = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.flight.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

  }

}

resource "aws_iam_role" "alb_controller" {

  name = "flight-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachment" {
    role = aws_iam_role.alb_controller.name
    policy_arn = aws_iam_policy.alb_controller.arn
}



# jenkin role;

resource "aws_iam_role" "jenkins_role" {
  name = "flight-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "flight-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}