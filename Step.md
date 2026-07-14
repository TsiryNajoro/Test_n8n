## 1 - Run n8n on premise

   - docker run -d \
    --name n8n \
    -p 5678:5678 \
    -v n8n_data:/home/node/.n8n \
    n8nio/n8n

[Optionally] If the URL provided by grok changed :

    a - Run this and replace the URL if needed :

    docker run -d \
    --name n8n \
    -p 5678:5678 \
    -v n8n_data:/home/node/.n8n \
    -e WEBHOOK_URL="https://prescribe-whinny-species.ngrok-free.dev" \
    n8nio/n8n

    b - curl -X POST https://nouvelle-url.ngrok-free.app/webhook/deploy

## 2 - Tunnel via 

   - ngrok http 5678

## 3 - Otherwise,

You'll have to make sure these following cases are correct :

- the IP adress in the SSH key configuration in n8n (Credential section)

- Eventually the github token in the Execute a command configuration, wether stored as an environment  variable or written in the command section

- The state of the workflow ([Published] or not)

- Your Application being launched before the test 

## 4 - The test 

Run your application first :

docker start test_n8n (your app name here)

git add . //Or what has been changed
git commit -m "Your commit"
git push

117164f73e81dd73d6bddd1dc7d2a0faee