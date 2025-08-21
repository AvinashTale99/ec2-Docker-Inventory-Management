pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'
        ECR_PUBLIC_REPO = 'public.ecr.aws/q7d5d6g9/avinash'
        IMAGE_NAME = 'avinash'
        GIT_REPO = 'https://github.com/AvinashTale99/ec2-Docker-Inventory-Management.git'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning repository..."
                git url: "${GIT_REPO}", branch: 'main'
                sh 'pwd && ls -la'
            }
        }

        stage('Login to Public ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-ecr-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws ecr-public get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_PUBLIC_REPO
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t $IMAGE_NAME:latest ."
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh """
                        docker tag $IMAGE_NAME:latest $ECR_PUBLIC_REPO:latest
                        docker tag $IMAGE_NAME:latest $ECR_PUBLIC_REPO:$commitId
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh """
                        docker push $ECR_PUBLIC_REPO:latest
                        docker push $ECR_PUBLIC_REPO:$commitId
                    """
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh """
                        docker rmi $IMAGE_NAME:latest || true
                        docker rmi $ECR_PUBLIC_REPO:$commitId || true
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Docker image successfully built and pushed to public ECR!'
        }
        failure {
            echo '❌ Build failed. Check logs for errors.'
        }
    }
}
