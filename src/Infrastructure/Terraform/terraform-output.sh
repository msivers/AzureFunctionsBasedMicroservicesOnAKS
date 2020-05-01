#!/bin/bash

if [[ ! -z "$AZURE_SUBSCRIPTION_ID" ]];then
    export TF_VAR_subscription_id=$AZURE_SUBSCRIPTION_ID
    echo "Subscription ID Env Var found"
fi

if [[ ! -z "$AZURE_CLIENT_ID" ]];then
    export TF_VAR_client_id=$AZURE_CLIENT_ID
    echo "Client ID Env Var found"
fi

if [[ ! -z "$AZURE_CLIENT_SECRET" ]];then
    export TF_VAR_client_secret=$AZURE_CLIENT_SECRET
    echo "Client Secret Env Var found"
fi

if [[ ! -z "$AZURE_TENANT_ID" ]];then
    export TF_VAR_tenant_id=$AZURE_TENANT_ID
    echo "Tenant ID Env Var found"
fi

terraform output 