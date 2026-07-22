# 1. Dynamically fetch the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "jenkins" {

    ami = data.aws_ami.ubuntu.id

    instance_type = var.instance_type_jenkins

    subnet_id = aws_subnet.public[0].id

    key_name = var.key_name

    vpc_security_group_ids = [
        aws_security_group.jenkins_sg.id
    ]

    iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

    user_data = file("${path.module}/user-data.sh")

    tags = {
        Name = "flight-jenkins"
    }
}