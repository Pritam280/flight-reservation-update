#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=================================================="
echo " Starting DevOps Toolchain Installation on Ubuntu "
echo "**************************************************"


# Update System Packages
echo "🔄 Updating system package index..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl unzip apt-transport-https ca-certificates gnupg software-properties-common

# 1. Install Java (OpenJDK 21 - Required for modern Jenkins)
echo "☕ Installing OpenJDK 21..."
sudo apt-get install -y openjdk-21-jdk

# 2. Install Git
echo "🐙 Installing Git..."
sudo apt-get install -y git

# 3. Install Docker
echo "🐳 Installing Docker Engine..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://docker.com | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://docker.com $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 4. Install AWS CLI
echo "☁️ Installing AWS CLI..."
curl "https://amazonaws.com" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# 5. Install kubectl
echo "☸️ Installing kubectl..."
KUBE_VERSION=$(curl -L -s https://k8s.io)
curl -LO "https://k8s.io{KUBE_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# 6. Install Helm
echo "⛵ Installing Helm..."
curl https://baltocdn.com | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update -y
sudo apt-get install -y helm

# 7. Install Jenkins
echo "🏗️ Installing Jenkins..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://jenkins.io
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://jenkins.io binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# 8. Post-Installation Configurations
echo "⚙️ Configuring permissions and services..."

# Enable and start services

sudo systemctl start docker --now
sudo systemctl start jenkins --now
sudo systemctl enable docker --now
sudo systemctl enable jenkins --now

# Add Jenkins user to the docker group so Jenkins can run Docker containers natively
sudo usermod -aG docker jenkins
# Also add the current user to the docker group
sudo usermod -aG docker $USER

echo "=================================================="
echo " ✅ Installation Complete Successfully! "
echo "=================================================="
echo "🌐 Access Jenkins UI via browser: http://your_server_ip:8080"
echo "🔑 Your initial Jenkins unlock password is:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "=================================================="
echo "⚠️  Note: Please reboot the server or log out/in for Docker group changes to take effect."
