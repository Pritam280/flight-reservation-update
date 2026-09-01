#!/bin/bash

exec > >(tee /var/log/jenkins-install.log | logger -t user-data) 2>&1

echo "================================================="
echo " Flight Reservation Jenkins Bootstrap Started"
echo "================================================="

###################################################
# Update OS
###################################################

apt-get update -y

apt-get install -y \
curl \
wget \
git \
unzip \
gnupg \
ca-certificates \
software-properties-common \
apt-transport-https

###################################################
# Install Java 21
###################################################

apt-get install -y openjdk-21-jdk

java -version

###################################################
# Install Docker
###################################################
sudo apt-get update -y
sudo apt-get install docker.io -y

systemctl start docker
systemctl enable docker

docker --version

###################################################
# Install AWS CLI v2
###################################################

cd /tmp

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip

unzip awscliv2.zip

./aws/install

aws --version

###################################################
# Install kubectl
###################################################

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client

###################################################
# Install Helm
###################################################

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version

###################################################
# Install Jenkins
###################################################
# Import Jenkins key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
| sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists
sudo apt-get update

# Install Jenkins
sudo apt-get install -y jenkins

###################################################
# Jenkins Docker Permissions
###################################################

usermod -aG docker jenkins
usermod -aG docker ubuntu

systemctl enable jenkins
systemctl start jenkins



###################################################
# Verify installations
###################################################

echo "========== Versions =========="

java -version

git --version

docker --version

aws --version

kubectl version --client

helm version

systemctl status docker --no-pager

systemctl status jenkins --no-pager

echo "========== AWS Identity =========="

aws sts get-caller-identity || true

###################################################
# Jenkins Password
###################################################

echo
echo "================================================="
echo " Jenkins Initial Password"
echo "================================================="

cat /var/lib/jenkins/secrets/initialAdminPassword

echo
echo "================================================="
echo " Jenkins installation completed successfully!"
echo "================================================="