#!/bin/bash

while getopts ":i:s:u:p:t:k:d:" opt; do
  case $opt in
    i) items="$OPTARG"
    ;;
    s) subscription_id="$OPTARG"
    ;;
    u) client_id="$OPTARG"
    ;;
    p) client_secret="$OPTARG"
    ;;
    t) tenant_id="$OPTARG"
    ;;
    k) key_vault="$OPTARG"
    ;;
    d) delimiter="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [[ -z "$items" ]];then
    echo "You must specify items (Key/Value) using the -i option.";
    exit 1
fi

if [[ -z "$subscription_id" ]];then
    echo "You must specify a subscription id using the -s option.";
    exit 1
fi

if [[ -z "$client_id" ]];then
    echo "You must specify a client id using the -u option.";
    exit 1
fi

if [[ -z "$client_secret" ]];then
    echo "You must specify a client secret using the -p option.";
    exit 1
fi

if [[ -z "$tenant_id" ]];then
    echo "You must specify a tenant id using the -t option.";
    exit 1
fi

if [[ -z "$key_vault" ]];then
    echo "You must specify a key vault name using the -k switch";
    exit 1
fi

if [[ -z "$delimiter" ]];then
    echo "No delimiter specified - will assume new line as delimiter";
    delimiter=$'\n'
fi

az login --service-principal -u $client_id -p $client_secret -t $tenant_id

az account set --subscription $subscription_id

s=$items$delimiter
array=();
while [[ $s ]]; do
    array+=( "${s%%"$delimiter"*}" );
    s=${s#*"$delimiter"};
done;

# Save current IFS
SAVEIFS=$IFS

for (( i=0; i<${#array[@]}; i++ ))
do
    # Change IFS to '='. 
    IFS=$'='
    
    read -r key value <<< "${array[$i]}"
    az keyvault secret set --vault-name "$key_vault" --name "$key" --value "$value"
    # echo "$key:$value"
done

# Restore IFS
IFS=$SAVEIFS