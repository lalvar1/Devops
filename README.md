# Introduction
Project to deploy a python app on an AKS cluster, using Terraform and Ansible for its CI/CD process.
This can be reutilized for multiple enviroments by defining the corresponding pipelines vars for each deployment

# Pipeline prerequistes 
## Commands variables
- SUBSCRIPTION=cf31015f-3cdf-45e4-96dd-706bebcf84a2
- TF_SP_NAME=dev-tf-sp
- TF_RG=dev-terraform-rg
- TF_LOCATION=westus
- BACKEND_RG=dev-terraform-backend-rg
- BACKEND_STG_ACCOUNT=devterraformbackenddemo
- BACKEND_CONTAINER=terraform-backend-files
- BACKEND_LOCATION=westus

## Create storage account and container where terraform will store the state file for the environment
- az group create -n $BACKEND_RG -l $BACKEND_LOCATION
- az storage account create --resource-group $BACKEND_RG --name $BACKEND_STG_ACCOUNT --sku Standard_LRS --encryption-services blob
- ACCOUNT_KEY=$(az storage account keys list --resource-group $BACKEND_RG --account-name $BACKEND_STG_ACCOUNT --query [0].value -o tsv)
- az storage container create --name $BACKEND_CONTAINER --account-name $BACKEND_STG_ACCOUNT --account-key $ACCOUNT_KEY
- echo $ACCOUNT_KEY

## Create AKS SP
- AKS_SP=$(az ad sp create-for-rbac -n dev-aks-sp --skip-assignment)
- AKS_CLIENT_ID=$(echo $AKS_SP | jq '.appId' | sed 's/"//g')
- AKS_CLIENT_SECRET=$(echo $AKS_SP | jq '.password' | sed 's/"//g')
- echo $AKS_CLIENT_ID
- echo $AKS_CLIENT_SECRET

## Create terraform general resources
- az group create -n $TF_RG -l $TF_LOCATION
- TF_SP=$(az ad sp create-for-rbac -n $TF_SP_NAME --role contributor --scopes "/subscriptions/$SUBSCRIPTION/resourceGroups/$BACKEND_RG/providers/Microsoft.Storage/storageAccounts/$BACKEND_STG_ACCOUNT" "/subscriptions/$SUBSCRIPTION/resourceGroups/$TF_RG")
- CLIENT_ID=$(az ad sp show --id http://$TF_SP_NAME --query appId --output tsv)
or
- CLIENT_ID=$(echo $TF_SP | jq '.appId' | sed 's/"//g')
- TENANT=$(az ad sp show --id http://$TF_SP_NAME --query tenant --output tsv)
- SECRET=$(az ad sp show --id http://$TF_SP_NAME --query password --output tsv)

# App Requirements
## Create a container registry
- az group create --name app-demo --location eastus
- az acr create --resource-group app-demo --name acrpydemo --sku Basic

## Service connections
Create ADO service connections for connecting with the following resources
- ACR
- AKS

# Static Code Analysis
- Create project and token and account token
- Create ADO Service connection 

# Post-deployment testing
## Connect to the cluster
- az login --service-principal -u $AKS_CLIENT_ID -p $AKS_CLIENT_SECRET --tenant $TENANT
- az account set --subscription $SUBSCRIPTION
- az aks get-credentials --resource-group $AKS_RG --name $AKS_CLUSTER_NAME --admin
# Get svc ip address 
- kubectl get svc
# Test app
- curl http://<service-external-ip-address>:<service-port>
