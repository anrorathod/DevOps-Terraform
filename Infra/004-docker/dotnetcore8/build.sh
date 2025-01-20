set -x
workspace=dev
subscription_id="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

az account set -s $subscription_id

if [[ $? -ne 0 ]]; then
    echo "Unable to switchto the subscription :"$subscription_id
    exit 1;
fi

az acr build  --registry demodevacr --image dotnetcore8:latest --file DockerFile .