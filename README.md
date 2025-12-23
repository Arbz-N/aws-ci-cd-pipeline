🚀 AWS CI/CD Pipeline for Python Flask Application

(GitHub → CodeBuild → CodeDeploy → EC2 via CodePipeline)

📌 Project Overview

This project demonstrates a fully automated CI/CD pipeline on AWS for a Python Flask application using AWS native services.

The pipeline performs the following actions:

Pulls source code from GitHub
Builds and containerizes the application using AWS CodeBuild
Pushes the Docker image to Docker Hub
Deploys the application on an EC2 instance using AWS CodeDeploy
Orchestrates the complete workflow using AWS CodePipeline

🎯 Goal:
To showcase secure, automated, and scalable application delivery using AWS CI/CD services.

🧰 Services Used

AWS CodePipeline
AWS CodeBuild
AWS CodeDeploy
AWS EC2
AWS Systems Manager (Parameter Store)
Amazon S3
Docker & Docker Hub
GitHub

🧱 CI/CD Workflow Stages

The entire process is divided into three stages:

Build & Image Creation (CodeBuild)
Application Deployment (CodeDeploy + EC2)
Pipeline Orchestration (CodePipeline)

🔨 Step 1: AWS CodeBuild – Build & Docker Image Creation
Why AWS CodeBuild?

AWS CodeBuild allows building, testing, and packaging applications without managing build servers.
It integrates securely with GitHub and other AWS services.

CodeBuild Configuration
Source Provider: GitHub
Webhook Enabled: ✅ Yes
Automatically triggers builds on every code push (Continuous Integration)
Operating System: Ubuntu
Privileged Mode: ✅ Enabled
Required to build Docker images inside CodeBuild

Service Role

A dedicated IAM role is attached to CodeBuild to allow access to:

AWS Systems Manager Parameter Store
Amazon S3 (artifacts)
Secure Docker authentication

📄 buildspec.yml – Build Specification

CodeBuild uses buildspec.yml to define the build steps.

    version: 0.2
    
    env:
      parameter-store:
        # Stored in AWS Systems Manager Parameter Store
        DOCKER_REGISTRY_USERNAME: /<PARAMETER_PATH>/docker-credentials/username
        DOCKER_REGISTRY_PASSWORD: /<PARAMETER_PATH>/docker-credentials/password
        DOCKER_REGISTRY_URL: /<PARAMETER_PATH>/docker-registry/url
    
    phases:
      install:
        runtime-versions:
          python: latest
        commands:
          - echo "Runtime environment ready"
    
      pre_build:
        commands:
          - pip install -r requirements.txt
    
      build:
        commands:
          - echo "$DOCKER_REGISTRY_PASSWORD" | docker login -u "$DOCKER_REGISTRY_USERNAME" --password-stdin "$DOCKER_REGISTRY_URL"
          - docker build -t "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/<IMAGE_NAME>:latest" .
          - docker push "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/<IMAGE_NAME>:latest"
    
      post_build:
        commands:
          - echo "Build completed successfully"
    
    artifacts:
      files:
        - "**/*"

📦 Artifacts Configuration (Amazon S3)

Stores build outputs and logs
Enables debugging, auditing, and data sharing between pipeline stages

🔐 Required IAM Permission for CodeBuild Role

Attach the following policy:

AmazonSSMFullAccess

This allows CodeBuild to securely fetch Docker credentials at runtime.

🚀 Step 2: AWS CodeDeploy – Application Deployment
Why AWS CodeDeploy?

AWS CodeDeploy automates application deployment on EC2 instances, ensuring controlled and repeatable releases.

🖥️ EC2 Setup for Deployment
EC2 Instance Configuration

Open Ports:

SSH (22)
HTTP (80)
HTTPS (443)

EC2 instance must be tagged for CodeDeploy targeting

CodeDeploy Agent Installation (Ubuntu)
Install the agent using the official AWS documentation:

🔗 https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-ubuntu.html

Docker Installation
Docker must be installed on EC2 to run the containerized Flask application.

🔑 IAM Roles
IAM Role for EC2

Attached Policies:

AWSCodeDeployFullAccess
AmazonEC2RoleforAWSCodeDeploy

Purpose:
Allows EC2 to:

Communicate with CodeDeploy
Pull Docker images
Execute deployment scripts

IAM Role for CodeDeploy

Use Case: CodeDeploy
Allows CodeDeploy to manage EC2 instances on your behalf.

📁 CodeDeploy Application & Deployment Group

EC2 instances are selected using tags
Load balancer is disabled (single EC2 deployment)

📄 appspec.yml – Deployment Specification

⚠️ Important:
This file must be placed in the root of the repository, otherwise deployment will fail.

    version: 0.0
    os: linux
    
    hooks:
      ApplicationStop:
        - location: scripts/stop_container.sh
          timeout: 300
          runas: root
    
      AfterInstall:
        - location: scripts/start_container.sh
          timeout: 300
          runas: root


Defines which scripts run and at which deployment stage.

🧩 Deployment Scripts
stop_container.sh
    #!/bin/bash
    set -e
    
    APP_NAME=<CONTAINER_NAME>
    docker stop $APP_NAME || true
    docker rm $APP_NAME || true

start_container.sh
    #!/bin/bash
    set -e
    
    APP_NAME=<CONTAINER_NAME>
    IMAGE=<DOCKER_IMAGE>
    PORT=5000

    docker pull $IMAGE
    docker run -d --name $APP_NAME -p $PORT:$PORT $IMAGE

🔄 Step 3: AWS CodePipeline – End-to-End Automation
Pipeline Stages

Source: GitHub
Build: AWS CodeBuild
Deploy: AWS CodeDeploy

CodePipeline orchestrates the entire CI/CD flow and ensures automatic deployment on every code change.

🌐 Application Access

After deployment:

Copy the public IP of the EC2 instance
Paste it into your browser
You will see the Python Flask application running

🔁 Continuous Deployment Test

Make a change in your .py file
Commit and push the changes to GitHub
The pipeline will automatically:
Trigger CodeBuild
Build & push a new Docker image
Deploy the updated application via CodeDeploy