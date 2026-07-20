
COMPREHENSIVE GUIDE of A CI/CD pipeline with : Docker, Jenkins, Github, n8n

## Notice : Since this setup was solely made for a demo, some configurations may vary once in real environement.
More specifically the usage of ngrok (tunneling jenkins to make it accessible by Github) or the self-hosted Github action runner ( to put it on the same network as the on premise installed n8n)

The step occuring:

- Someone Push code 
- Pipeline jenkins (build and push image + trigger Github action for the event) 
- Github actions runner (send the webhook to n8n)
- n8n ( pull + deploy the image )

# All configurations :

- On n8n :
    # Config :
    - Add an SSH key in the credential section by filling the form, then save it after the test was successfull
    - Add 2 nodes : Webhook +  Execute a command 
    - on the webhook node  : 
        - Fill the "path" input, which will be used on the production and test URL (of your  choice)

    - on the Execute a command node : 
        - Choose the previously added SSH key in the credential input 
        - On the command input, put a basic command such as "docker version" to make sure n8n has access to the server, Execute the workflow(imperatively not on the "Published" state) and make a POST request with the webhook test URL on a console 
        - If the test succeeded, add the correct command for the deployment here
            Notice : All the variables (GHCR login info) needed for that command should be placed in the variable section of n8n for security reason, but since that feature isn't accessible in the free plan, those variables had to be used in the command itself for the test

    - If everything is all set, publish the workflow


- On Jenkins :
    # Config :
    - Install all the required plugin 
    - Add a Personal Access token secret in the Github credentials section with the repo, writte & read packages scope 
    - Create the pipeline and configure it by adding the repository URL and Add a trigger by checking "GitHub hook trigger for GITScm polling"
    - make sure the Jenkinsfile is correct

- On Github :
    # Config :
    - make sure there's a correct deployment file in the github workflow repertory


