
resource "aws_eks_cluster" "flight_cluster" {
    name = "flight-eks-cluster"
    role_arn = aws_iam_role.eks_cluster_role.arn

    version = var.eks_version

    vpc_config {
        subnet_ids = concat(
                            aws_subnet.public[*].id,
                            aws_subnet.private[*].id
                            )
        security_group_ids = [aws_security_group.backend_app_sg.id]

    }
    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy,
        #aws_iam_role_policy_attachment.eks_service_policy
    ]
  
}

resource "aws_eks_node_group" "flight_node_group" {
    cluster_name = aws_eks_cluster.flight_cluster.name
    node_group_name = "flight-eks-node-group"
    node_role_arn = aws_iam_role.eks_node_role.arn
    subnet_ids = aws_subnet.private[*].id

    scaling_config {
        desired_size = var.desired_size
        max_size = var.max_size
        min_size = var.min_size
    }

    instance_types = var.instance_type

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_worker_node_policy,
        aws_iam_role_policy_attachment.eks_cni_policy,
        aws_iam_role_policy_attachment.eks_container_policy
     ]
}