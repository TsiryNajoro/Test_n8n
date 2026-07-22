### CI part :

## Jenkins 

- Plugin installation
- Add the 2 required credentials:
    A GitHub Personal Access Token (PAT) with the required repository and workflow permissions.
    A GitHub Container Registry (GHCR) authentication token with the read:packages and write:packages scopes. Note their IDs for future use (github-pat and ghcr-token in this context).
- create the pipeline
- Enable the trigger: GitHub hook trigger for GITScm polling
- Configure the pipeline source as: Pipeline script from SCM (Git)
- Set the repository URL
- Apply and save

## Application side

- Make sure there's a Jenkinsfile with this following content on the root of the repository :
----------------------------------------------------------------------------------
pipeline {
    agent any

    environment {
        IMAGE_NAME = "ghcr.io/YOUR_GITHUB_ORG/YOUR_IMAGE_NAME"
        GITHUB_REPO = "GITHUB_NAME/REPO_NAME"
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

        stage('Trigger GitHub Actions') {
            steps {
                withCredentials([
                    string(credentialsId: 'github-pat', variable: 'GH_PAT')
                ]) {
                    sh '''
                    curl -X POST \
                      -H "Authorization: token ${GH_PAT}" \
                      -H "Accept: application/vnd.github+json" \
                      https://api.github.com/repos/${GITHUB_REPO}/dispatches \
                      -d "{\\"event_type\\":\\"docker-image-published\\",\\"client_payload\\":{\\"tag\\":\\"${BUILD_NUMBER}\\"}}"
                    '''
                }
            }
        }

    }
}
---------------------------------------------------------------------------------
In summary, this part describes the automation of the code-to-image lifecycle, from application source code changes to Docker image creation and publication on GHCR.


The CI pipeline ends when the Docker image is successfully published to GHCR. The CD pipeline starts from this artifact and is responsible for deploying the corresponding version on the target environment.

### CI/CD handover

Once the Docker image is built and pushed to GHCR, the CI part is considered completed.

The communication between CI and CD is done using a repository_dispatch event.

Instead of relying on GitHub native package events (registry_package), Jenkins explicitly triggers the GitHub Actions workflow through the GitHub API and sends the image tag as a parameter.

The workflow trigger mechanism must be clearly communicated between both teams to avoid integration issues.


### CD part :

## n8n 
- Add a new credential using an SSH key previously created on the target server, and make sure the connectivity test success before saving it
- Create a new workflow, add two nodes: Webhook and Execute Command., and link them together
    # on the Webhook node :
     - fill the path with one of your choice, and leave the remaining as they are
     - Save the Production URL, as it will be used later by the deployment pipeline.
    # on the execute a command node :
     - Open it, and add the SSH key previously added on the credential input
     - In the command section, use a simple command such as docker version to verify SSH connectivity between n8n and the target server.
     - Execute the webhook and make a curl POST method on the test URL from a console 
     - if the test succeeds, fill your deployment script in the command section
     - publish the workflow

     Notice : Store sensitive variables in n8n credentials or environment variables for security purposes. IMAGE_NAME, CONTAINER_NAME, HOST_PORT, CONTAINER_PORT, GHCR_USER and GHCR_TOKEN

The deployment script :
---------------------------------------------------------------------------------

#!/bin/bash

TAG="{{ $json.body.tag }}"
FULL_IMAGE="$IMAGE_NAME:$TAG"

echo "Image deployment : $FULL_IMAGE"

cd [the correct directory on the server ] || exit 1

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin

docker pull "$FULL_IMAGE"

if docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$HOST_PORT:$CONTAINER_PORT" \
    "$FULL_IMAGE"

echo "Deployment sucessful! Image: $FULL_IMAGE"
---------------------------------------------------------------------------------



## On the repository 

- Create a deployment workflow file inside the .github/workflows directory. The purpose of this workflow is to notify n8n that a new image is available and provide the image tag required for deployment.

deploy.yml : 
---------------------------------------------------------------------------------
name: Trigger n8n Deployment

on:
  repository_dispatch:
    types: [docker-image-published]

concurrency:
  group: deploy
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - name: Send webhook to n8n
        run: |
          TAG="${{ github.event.client_payload.tag }}"

          echo "tag deployment: $TAG"

          curl -X POST [n8n webhook Production URL]\
            -H "Content-Type: application/json" \
            -d "{\"tag\":\"$TAG\"}"

          echo "Webhook envoyé à n8n"
---------------------------------------------------------------------------------
Note: The runner type may vary depending on the infrastructure architecture and network connectivity requirements.