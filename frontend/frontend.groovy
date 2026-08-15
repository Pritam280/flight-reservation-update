pipeline {
    agent any
    environment {

        AWS_REGION = "us-east-1"
        S3_BUCKET = "flight-frontend"
        DISTRIBUTION_ID = "E3QZ0X1Y2Z3A4B"

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

        stage('Build'){
            steps {
                dir('frontend') {
                    sh 'npm run build'
                }
            }
        }

        stage('Deploy to S3') {
            steps {
                sh """
                aws s3 sync frontend/build/ s3://${S3_BUCKET} --delete
                """
            }
        }

        stage('Invalidate Cloudfront chache') {
            steps {
                sh """
                aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths "/*"
                
                """
            }
        }
    }
}