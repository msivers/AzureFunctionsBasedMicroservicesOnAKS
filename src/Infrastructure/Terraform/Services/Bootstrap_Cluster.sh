#!/usr/bin/env bash


# Verify dependencies
echo "\n\n\n***** VERIFY DEPENDENCIES *****\n\n"


# Check for terraform
declare terraform_version_output
terraform_version_output=$(terraform version 2>&1)
if [ $? -ne 0 ]; then
    echo "terraform required on PATH..."
    exit 1
else
    echo "terraform version: ${terraform_version_output}"
fi

# Check for jq (JSON Query)
declare jq_version_output
jq_version_output=$(jq --version 2>&1)
if [ $? -ne 0 ]; then
    echo "jq required on PATH..."
    exit 1
else
    echo "jq version: ${jq_version_output}"
fi

# Check for kubectl
declare kubectl_version_output
kubectl_version_output=$(kubectl version --client 2>&1)
if [ $? -ne 0 ]; then
    echo "kubectl required on PATH..."
    exit 1
else
    echo "kubectl version: ${kubectl_version_output}"
fi



echo "\n\n\n***** GET TERRAFORM VARS FROM STATE *****\n\n"

# Terraform init
echo "Run terraform init script.."
terraform init -input=false -no-color

# Get variables from terraform state...
terraform state pull > bootstrap_cluster_remote_state

subscription_id=$(cat bootstrap_cluster_remote_state | jq --raw-output '.outputs.subscription_id.value')
resource_group=$(cat bootstrap_cluster_remote_state | jq --raw-output '.outputs.resource_group_name.value')

application_gateway_name=$(cat bootstrap_cluster_remote_state | jq --raw-output '.outputs.application_gateway_name.value')
identity_resource_id=$(cat bootstrap_cluster_remote_state | jq --raw-output '.outputs.identity_resource_id.value')
identity_client_id=$(cat bootstrap_cluster_remote_state | jq --raw-output '.outputs.identity_client_id.value')
cluster_name=$(cat bootstrap_cluster_remote_state | jq --raw-output '.outputs.cluster_name.value')
host=$(cat bootstrap_cluster_remote_state | jq --raw-output '.outputs.host.value')
rm bootstrap_cluster_remote_state



echo "\n\n\n***** AZ LOGIN + GET AKS CREDS *****\n\n"

# Azure CLI Login
declare azure_cli_login_output
azure_cli_login_output=$(az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID 2>&1)
if [ $? -ne 0 ]; then
    echo "Error logging in with az login..."
    echo "Error: $azure_cli_login_output"
    exit 1
else
    echo "$azure_cli_login_output"
fi

if [[ -z "$AZURE_SUBSCRIPTION_ID" ]];then
    [[ ! -z "$subscription_id" ]] && export AZURE_SUBSCRIPTION_ID=$subscription_id
fi

declare azure_cli_set_sub_output
azure_cli_set_sub_output=$(az account set --subscription $AZURE_SUBSCRIPTION_ID  2>&1)
if [ $? -ne 0 ]; then
    echo "Error logging in with az login..."
    echo "Error: $azure_cli_set_sub_output"
    exit 1
else
    echo "$azure_cli_set_sub_output"
fi

# Get kubectl credentials for cluster from Azure CLI
declare get_credentials_output
get_credentials_output=$(az aks get-credentials --overwrite-existing --resource-group $resource_group --name $cluster_name --admin 2>&1)
if [ $? -ne 0 ]; then
    echo "Failed to get administrative credentials for kubectl.."
    echo "Error: $get_credentials_output"
    exit 1
else
    echo "$get_credentials_output"
fi



echo "\n\n\n***** VERIFY OR INSTALL HELM 3 *****\n\n"

# Install Helm v3
declare helm3_version_output
helm3_version_output=$(helm3 version 2>&1)
if [ $? -ne 0 ]; then
    echo "helm3 required on PATH.. Installing if on Linux/Mac.."
    # Install Helm v3.0.0-beta.5 if on Linux
    if [[ $(uname) == *"Linux"* ]]; then
        mkdir bootstrap_cluster_helm3_install
        cd bootstrap_cluster_helm3_install
        wget --quiet --output-document="helm3.tar.gz" "https://get.helm.sh/helm-v3.0.1-linux-amd64.tar.gz"
        tar -xvf helm3.tar.gz
        sudo mv linux-amd64/helm /usr/local/bin/helm3
        cd ..
        rm -r bootstrap_cluster_helm3_install
        echo "helm3 installed."
        helm3_version_output=$(helm3 version 2>&1)
    elif [[ $(uname) == *"Darwin"* ]]; then
        mkdir bootstrap_cluster_helm3_install
        cd bootstrap_cluster_helm3_install
        curl -o "helm3.tar.gz" "https://get.helm.sh/helm-v3.0.1-darwin-amd64.tar.gz"
        tar -xvf helm3.tar.gz
        sudo mv darwin-amd64/helm /usr/local/bin/helm3
        cd ..
        rm -r bootstrap_cluster_helm3_install
        echo "helm3 installed."
        helm3_version_output=$(helm3 version 2>&1)
    else
        echo "Can't install as this is not a Linux or MacOS environment."
        exit 1
    fi
fi
echo "helm3 version output: ${helm3_version_output}"



echo "\n\n\n***** INSTALL AAD POD IDENTITY *****\n\n"

# Install Azure AD Pod Identity 
declare aadpodidentity_install_output
aadpodidentity_install_output=$(kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment.yaml 2>&1)
if [ $? -ne 0 ]; then
    echo "Failed to install/update Azure AD Pod Identity"
    echo "Error: $aadpodidentity_install_output"
    exit 1
else
    echo "Azure AD POD Identity Installed/Updated."
fi



echo "\n\n\n***** INSTALL KEDA *****\n\n"

# Create keda namespace
declare create_keda_ns_output
create_keda_ns_output=$(kubectl create namespace keda 2>&1)
if [ $? -ne 0 ]; then
    if [[ ${create_keda_ns_output} == *"already exists"* ]]; then 
        echo "Namespace 'keda' exists."
    else 
        echo "Failed to create 'keda' namespace."
        echo "Error: $create_keda_ns_output"
        exit 1
    fi
else
    echo "Namespace 'keda' created."
fi

# Install KEDA
helm3 repo add kedacore https://kedacore.github.io/charts
helm3 repo update
helm3 upgrade keda kedacore/keda --namespace keda --install



echo "\n\n\n***** INSTALL AGIC *****\n\n"

# Create services namespace
declare create_services_ns_output
create_services_ns_output=$(kubectl create namespace services 2>&1)
if [ $? -ne 0 ]; then
    if [[ ${create_services_ns_output} == *"already exists"* ]]; then 
        echo "Namespace 'services' exists."
    else 
        echo "Failed to create 'services' namespace."
        echo "Error: $create_services_ns_output"
        exit 1
    fi
else
    echo "Namespace 'services' created."
fi

# Install AGIC
helm3 repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm3 repo update

helm_config_file=helm-config.yaml
curl -o $helm_config_file https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/sample-helm-config.yaml
if [ ! -f "$helm_config_file" ]; then
    echo "$helm_config_file file not downloads?"
    exit 1
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/<subscriptionId>/$subscription_id/g" $helm_config_file
else
    sed -i "s/<subscriptionId>/$subscription_id/g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/<resourceGroupName>/$resource_group/g" $helm_config_file
else
    sed -i "s/<resourceGroupName>/$resource_group/g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/<applicationGatewayName>/$application_gateway_name/g" $helm_config_file
else
    sed -i "s/<applicationGatewayName>/$application_gateway_name/g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s|<identityResourceId>|$identity_resource_id|g" $helm_config_file
else
    sed -i "s|<identityResourceId>|$identity_resource_id|g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/<identityClientId>/$identity_client_id/g" $helm_config_file
else
    sed -i "s/<identityClientId>/$identity_client_id/g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s|<aks-api-server-address>|$host|g" $helm_config_file
else
    sed -i "s|<aks-api-server-address>|$host|g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/# kubernetes/kubernetes/g" $helm_config_file
else
    sed -i "s/# kubernetes/kubernetes/g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/#   watchNamespace/  watchNamespace/g" $helm_config_file
else
    sed -i "s/#   watchNamespace/  watchNamespace/g" $helm_config_file
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/<namespace>/services/g" $helm_config_file
else
    sed -i "s/<namespace>/services/g" $helm_config_file
fi

helm3 upgrade --install -f $helm_config_file ingress-agic application-gateway-kubernetes-ingress/ingress-azure --set appgw.usePrivateIP=false --namespace services