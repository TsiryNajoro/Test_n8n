pipeline {
    agent any

    stages {

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                    -t test_n8n:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Check Image') {
            steps {
                sh 'docker images | grep test_n8n'
            }
        }
    }
}