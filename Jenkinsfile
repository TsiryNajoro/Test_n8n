pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/TsiryNajoro/Test_n8n.git'
            }
        }

        stage('Test') {
            steps {
                sh 'ls -la'
                echo 'Code récupéré avec succès 🚀'
            }
        }
    }
}