pipeline {
    agent any

    environment {
        IMAGE_NAME = "ghcr.io/tsirynajoro/test_n8n"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'ghcr-token',
                        usernameVariable: 'GH_USER',
                        passwordVariable: 'GH_TOKEN'
                    )
                ]) {
                    sh '''
                    echo $GH_TOKEN | docker login ghcr.io -u $GH_USER --password-stdin

                    docker push ${IMAGE_NAME}:${BUILD_NUMBER}

                    docker logout ghcr.io
                    '''
                }
            }
        }

    }
}