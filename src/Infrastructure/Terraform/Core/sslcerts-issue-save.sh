#!/bin/bash

# Azure DNS Environment Variables (required for acme.sh)
if [[ ! -z "$4" ]];then
    export AZUREDNS_SUBSCRIPTIONID=$1
    export AZUREDNS_APPID=$2
    export AZUREDNS_CLIENTSECRET=$3
    export AZUREDNS_TENANTID=$4
    echo "acme.sh environment variables set"
else
    echo "Error: acme.sh environment variables not set!";
    exit 1
fi

if [[ ! -z "$5" ]];then
    export KEY_VAULT_NAME=$5
else
    echo "No Key Vault name provided.";
    exit 1
fi

if [[ ! -z "$6" ]];then
    export HOSTNAME=$6
else
    export HOSTNAME="*.domain.com"
fi

curl https://get.acme.sh | sh

~/.acme.sh/acme.sh --issue --dns dns_azure --dnssleep 30 --force -d $HOSTNAME --post-hook '~/.acme.sh/acme.sh --toPkcs -d $HOSTNAME --password $AZUREDNS_CLIENTSECRET'


az login --service-principal -u $AZUREDNS_APPID -p $AZUREDNS_CLIENTSECRET --tenant $AZUREDNS_TENANTID
az account set --subscription $AZUREDNS_SUBSCRIPTIONID

# Add as certificate and add as secret for pfx file content and password.
az keyvault certificate import --vault-name $KEY_VAULT_NAME -n RevPlatSslCert -f ~/.acme.sh/$HOSTNAME/$HOSTNAME.pfx --password $AZUREDNS_CLIENTSECRET

# pfxdata=$(cat ~/.acme.sh/$HOSTNAME/$HOSTNAME.pfx | base64)
# az keyvault secret set --vault-name $KEY_VAULT_NAME -n RevPlatSslCertPfx --value "$pfxdata"
# az keyvault secret set --vault-name $KEY_VAULT_NAME -n RevPlatSslCertPassword --value "$AZUREDNS_CLIENTSECRET"