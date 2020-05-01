# export DROP_SUB_ID="?"
# export DROP_CLIENT_ID="?"
# export DROP_CLIENT_SECRET="?"
# export DROP_TENANT_ID="?"
# export DROP_RESOURCE_PREFIX="rp"
# export DROP_RESOURCE_ENV="dev"

# Azure CLI Login
declare azure_cli_login_output
azure_cli_login_output=$(az login --service-principal --username $DROP_CLIENT_ID --password $DROP_CLIENT_SECRET --tenant $DROP_TENANT_ID 2>&1)
if [ $? -ne 0 ]; then
    echo "Error logging in with az login..."
    echo "Error: $azure_cli_login_output"
    exit 1
else
    echo "$azure_cli_login_output"
fi

declare azure_set_sub_output
azure_set_sub_output=$(az account set --subscription $DROP_SUB_ID 2>&1)
echo azure_set_sub_output

az group delete --name "$DROP_RESOURCE_PREFIX-$DROP_RESOURCE_ENV-services-rg"
az group delete --name "$DROP_RESOURCE_PREFIX-$DROP_RESOURCE_ENV-data-rg"
az group delete --name "$DROP_RESOURCE_PREFIX-$DROP_RESOURCE_ENV-core-rg"
az group delete --name "$DROP_RESOURCE_PREFIX-global-rg"