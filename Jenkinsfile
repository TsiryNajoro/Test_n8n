pipeline {
    agent any

    environment {
        IMAGE_NAME = "ghcr.io/tsirynajoro/test_n8n"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t test_n8n:${BUILD_NUMBER} .
                '''
            }
        }


        stage('Login GHCR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'ghcr-token',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )
                ]) {

                    sh '''
                    echo $GHCR_TOKEN | docker login ghcr.io \
                    -u $GHCR_USER \
                    --password-stdin
                    '''

                }
            }
        }


        stage('Tag Image') {
            steps {
                sh '''
                docker tag \
                test_n8n:${BUILD_NUMBER} \
                ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }


        stage('Push Image') {
            steps {
                sh '''
                docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }


        stage('Check Image') {
            steps {
                sh '''
                docker images | grep test_n8n
                '''
            }
        }

    }
}