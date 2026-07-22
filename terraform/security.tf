resource "aws_security_group" "lb_sg" {
    name = "flight-lb-sg"
    description = "allow public traffic to load balancer"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow http traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "allow https traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "allow outbound traffic to internet"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "flight_public_lb_sg"
    }
}

# private app server traffic

resource "aws_security_group" "backend_app_sg" {
    name = "flight_private_app_sg"
    description = "allow traffic strictly from Load balancer"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow http from LB"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.lb_sg.id]
    }

    egress {
        description = "allow outbound traffic to internet via Nat gateway"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "flight_private_app_sg"
    }
}

resource "aws_security_group" "db_sg" {
    name = "flight_private_db_sg"
    description = "allow db traffic from app server "
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow mysql traffic from app server"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_eks_cluster.flight_cluster.vpc_config[0].cluster_security_group_id]
    }
    egress {
        description = "allow outbound traffic to internet via nat"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "flight_private_db_sg"
    }
}

resource "aws_security_group" "jenkins_sg" {

  name = "flight-jenkins-sg"

  vpc_id = aws_vpc.main.id

  ingress {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
  }

  ingress {
      from_port = 8080
      to_port   = 8080
      protocol  = "tcp"
  }

  egress {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
  }
}