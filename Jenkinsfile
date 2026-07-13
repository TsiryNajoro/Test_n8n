stage('Push Docker Image') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'ghcr-token',
                usernameVariable: 'GH_USER',
                passwordVariable: 'GH_TOKEN'
            )
        ]) {
            sh '''
            echo $GH_TOKEN | docker login ghcr.io \
            -u $GH_USER \
            --password-stdin

            docker tag test_n8n:${BUILD_NUMBER} \
            ghcr.io/tsirynajoro/test_n8n:${BUILD_NUMBER}

            docker push \
            ghcr.io/tsirynajoro/test_n8n:${BUILD_NUMBER}
            '''
        }
    }
}