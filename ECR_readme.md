
**GitHub Repository**:
[https://github.com/AvinashTale99/ec2-Docker-Inventory-Management.git](https://github.com/AvinashTale99/ec2-Docker-Inventory-Management.git)

Here's your comprehensive `README.md`, including:

* A polished project overview
* Installation script runner (`jenkins-install.sh`)
* Detailed EC2 and IAM setup steps
* Jenkins pipeline configuration and the `Jenkinsfile`
* How to run it all as a zip-download

---

````markdown
# EC2 Docker Inventory Management — CI/CD with Jenkins

This project showcases how to set up a continuous integration and deployment (CI/CD) pipeline that builds and pushes a Docker image of the Inventory Management app on an AWS EC2 instance running Jenkins.

---

##  Table of Contents

- [Architecture Overview](#architecture-overview)  
- [Prerequisites](#prerequisites)  
- [Installation Script: `jenkins-install.sh`](#installation-script-jenkins-installsh)  
- [AWS Infrastructure Setup](#aws-infrastructure-setup)  
  - [EC2 Instance Creation](#ec2-instance-creation)  
  - [IAM User/Role Configuration](#iam-userrole-configuration)  
- [Jenkins Setup](#jenkins-setup)  
  - [Access & Plugins](#access--plugins)  
  - [Credentials: AWS ECR](#credentials-aws-ecr)  
- [Pipeline Configuration (`Jenkinsfile`)](#pipeline-configuration-jenkinsfile)  
- [Repository Structure](#repository-structure)  
- [Getting Started](#getting-started)  
- [Author & License](#author--license)  

---

## Architecture Overview

Your Jenkins CI/CD pipeline will:

1. Deploy on an **AWS EC2 t2.large instance**  
2. Build the Docker image of the Inventory Management app  
3. Tag images with `latest` and Git commit hash  
4. Push images to **AWS Public ECR**  
5. Clean up local Docker images  

---

## Prerequisites

| Tool/Service       | Requirement                                          |
|--------------------|------------------------------------------------------|
| AWS Account        | With EC2 and ECR access                              |
| IAM (User or Role) | With ECR permissions                                 |
| Jenkins            | Installed on your EC2 instance                       |
| Docker & Java      | Installed on the EC2 instance                        |
| GitHub Repository  | `ec2-Docker-Inventory-Management`                    |

---

## Installation Script: `jenkins-install.sh`

Save the script below on your EC2 instance and run it to install Jenkins, Docker, Java 21, and Maven:

```bash
#!/bin/bash
# jenkins-install.sh

set -e
echo "🔄 Updating system packages..."
sudo yum update -y

echo "📦 Installing Docker and Git..."
sudo yum install -y git docker

echo "☕ Installing Amazon Corretto Java 21..."
sudo dnf install -y java-21-amazon-corretto

echo "✅ Java version:"
java --version

echo "📦 Installing Maven..."
sudo yum install -y maven

echo "✅ Maven version:"
mvn -v

echo "📥 Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "⬆️ Upgrading system packages..."
sudo yum upgrade -y

echo "🚀 Installing Jenkins..."
sudo yum install -y jenkins

echo "✅ Jenkins version:"
jenkins --version

echo "👥 Adding Jenkins user to Docker group..."
sudo usermod -aG docker jenkins

echo "🔧 Starting and enabling Docker and Jenkins services..."
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "✅ Jenkins installation complete!"
echo "🌐 Access Jenkins on: http://<your-server-ip>:8080"
echo "🔐 Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
````

---

## AWS Infrastructure Setup

### EC2 Instance Creation

* **Instance Type**: `t2.large`
* **AMI**: Amazon Linux 2
* **Security Group Rules**:

  * SSH: TCP 22 (Your IP only)
  * HTTP: TCP 80 (Optional)
  * Jenkins: TCP 8080 (Anywhere or restricted)

### IAM User or Role

Attach these IAM policies for ECR access:

```json
[
  "AmazonEC2ContainerRegistryPublicFullAccess",
  "AmazonEC2ContainerRegistryFullAccess"
]
```

* **If using User**: Create access key and secret key for Jenkins credentials
* **If using Role**: Assign to the EC2 instance directly

---

## Jenkins Setup

### Access & Required Plugins

1. Browse `http://<ec2-ip>:8080` and unlock Jenkins with the printed password.
2. Install recommended plugins: **Pipeline**, **Git**, **Docker Pipeline**, **Credentials Binding**

### AWS ECR Credentials in Jenkins

* Manage Jenkins → Credentials → System → Global credentials (unrestricted)
* Add Credentials:

  * **Kind**: Username with password
  * **ID**: `aws-ecr-creds`
  * **Username**: AWS Access Key ID
  * **Password**: AWS Secret Access Key
  * **Description**: `AWS ECR Credentials`

---

## Pipeline Configuration (`Jenkinsfile`)

Place this file in your GitHub repo root (`ec2-Docker-Inventory-Management/Jenkinsfile`):

```groovy
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
```

---

## Repository Structure

```
ec2-Docker-Inventory-Management/
├── Dockerfile
├── Jenkinsfile
├── README.md ← **(You are here!)**
└── src/… (application code)
```

---

## Getting Started

1. Clone this repo to your EC2 instance:

   ```bash
   git clone https://github.com/AvinashTale99/ec2-Docker-Inventory-Management.git
   ```
2. Run installation script:

   ```bash
   cd ec2-Docker-Inventory-Management
   chmod +x jenkins-install.sh
   ./jenkins-install.sh
   ```
3. Setup Jenkins, credentials, and pipeline as described above.
4. Upon pushing to GitHub, Jenkins will automatically build, tag, and push your Docker images to AWS Public ECR.

---

## Author & License

* **Author**: Avinash Anant Tale
* **License**: MIT

Happy building!

```

---


::contentReference[oaicite:0]{index=0}
```
