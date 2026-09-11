
pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        S3_BUCKET = "flight-2-bucket-014445"
        DISTRIBUTION_ID = "ETJ0BDHOHUPPH"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'npm run build'
                }
            }
        }

        stage('Deploy to S3') {
            steps {
                sh """
                    aws s3 sync frontend/dist/ s3://${S3_BUCKET} --delete
                """
            }
        }

        stage('Invalidate CloudFront Cache') {
            steps {
                sh """
                    aws cloudfront create-invalidation \
                    --distribution-id ${DISTRIBUTION_ID} \
                    --paths "/*"
                """
            }
        }
    }

    post {
        success {
            echo "Frontend deployment successful"
        }

        failure {
            echo "Frontend deployment failed"
        }
    }
}

