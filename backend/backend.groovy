pipeline {
    agent any

    # define environments vairables
    envirnments {
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = "882040517501"
        ECR_REPOSITORY = "flight-backend-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        CLUSTER_NAME = "flight-eks-cluster"
        NAMESPACE = "flight-reservation"
        DEPLOYMENT = "flight-reservation-app"
        CONTAINER = "flight-reservation-app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('build backend') {
            steps {
                dir('backend') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('backend') {
                    sh """
                        docker build \
                            -t ${ECR_REPOSITORY}:${IMAGE_TAG} .
                        """
                    }
                }
                
            }

            stage('Login to ECR') {
                steps {
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} |
                    docker login --username AWS --password-stdin \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    """
                }
            }

            stage('Push Image') {
                steps {
                    sh """
                    docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}

                    docker push \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}
                    """
                }
            }

            stage('Deploy to k8s') {
                steps {
                    sh """
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

                    kubectl set image deployment/${Deployment} \
                    ${CONTAINER}=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG} \
                    -N ${NAMESPACE}
                    """
                }
            }

            stage('verify Rollout') {
                steps {
                    sh """
                    kubectl rollout status deployment/${DEPLOYMENT} -n ${NAMESPACE}
                    kubectl get pods -n ${NAMESPACE}

                    """
                }
            }

    }
    post {
        success {
            echo "Deployment successful"
        }

        failure {
            echo "deployment failed"
        }
    }
}
