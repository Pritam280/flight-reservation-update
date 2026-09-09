
output "vpc_id" {
    description = "vpc id"
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    value = aws_subnet.public[*].id
}

output "private_subnet_id" {
    value = aws_subnet.private[*].id
}


output "lb_sg_id" {
    description = "security group id for Load balancer"
    value = aws_security_group.lb_sg.id
}

output "backend_app_sg_id" {
    description = "id for app server"
    value = aws_security_group.backend_app_sg.id
}

output "db_sg_id" {
    value = aws_security_group.db_sg.id
}

output "cluster_name" {
    value = aws_eks_cluster.flight_cluster.name
}

output "cluster_endpoint" {
    value = aws_eks_cluster.flight_cluster.endpoint
}

output "cluster_certificate_authority" {
    value = aws_eks_cluster.flight_cluster.certificate_authority[0].data
}

output "cluster_oidc_issuer" {
    value = aws_eks_cluster.flight_cluster.identity[0].oidc[0].issuer
}


# s3 bucket
/*
output "website_endpoint" {
    value = aws_s3_bucket.flight_bucket.website_endpoint
    description = "URL to access the static website"
}
*/


output "bucket_name" {
    value = aws_s3_bucket.flight_bucket.bucket
    description = "Name of the S3 bucket"
}

output "rds_endpoint" {
    value = aws_db_instance.fligth_db.endpoint
    description = "RDS endpoint"
}

output "ecr_repository_url" {
    value = aws_ecr_repository.flight_backend_app.repository_url
}

output "ecr_repository_name" {
    value = aws_ecr_repository.flight_backend_app.name
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "aws_cloudfront_distribution_domain_name" {
    value = aws_cloudfront_distribution.frontend.domain_name
}


# CloudFront
##########################################

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend.id
}

##########################################
# Route53
##########################################


#output "frontend_url" {
#  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
#}


#output "backend_url" {
#  value = "https://${aws_route53_record.backend.name}"
#}



output "jenkins_public_ip" {
    value = aws_instance.jenkins.public_ip
}

output "jenkins_public_dns" {
    value = aws_instance.jenkins.public_dns
}

output "jenkins_instance_id" {
    value = aws_instance.jenkins.id
}


