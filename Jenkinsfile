
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'govt-benefits-assistant'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Downloading source code from GitHub'
                checkout scm
            }
        }

        stage('Python Validation') {
            steps {
                echo 'Checking Python application'
                bat 'python --version'
                bat 'python -m compileall -q app.py engine'
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    bat 'docker build -t %DOCKER_USER%/%IMAGE_NAME%:%BUILD_NUMBER% .'
                    bat 'docker tag %DOCKER_USER%/%IMAGE_NAME%:%BUILD_NUMBER% %DOCKER_USER%/%IMAGE_NAME%:latest'
                }
            }
        }

        stage('Docker Login and Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    bat 'echo %DOCKER_TOKEN%| docker login -u %DOCKER_USER% --password-stdin'
                    bat 'docker push %DOCKER_USER%/%IMAGE_NAME%:%BUILD_NUMBER%'
                    bat 'docker push %DOCKER_USER%/%IMAGE_NAME%:latest'
                    bat 'docker logout'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    bat 'powershell -NoProfile -Command "(Get-Content deployment.yaml -Raw).Replace(''YOUR_DOCKERHUB_USERNAME'', $env:DOCKER_USER).Replace(''IMAGE_TAG'', $env:BUILD_NUMBER) | Set-Content deployment-ci.yaml"'

                    bat 'kubectl apply -f deployment-ci.yaml'
                    bat 'kubectl apply -f service.yaml'
                    bat 'kubectl rollout status deployment/govt-benefits-deployment --timeout=180s'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                bat 'kubectl get deployments'
                bat 'kubectl get pods'
                bat 'kubectl get services'
            }
        }
    }

    post {
        success {
            echo 'Government Benefits Assistant deployed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
