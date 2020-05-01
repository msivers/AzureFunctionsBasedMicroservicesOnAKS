#!/bin/bash

apiBaseUrl=$1
apiAccessKey=$2
variableGroupName=$3
variableKey=$4
variableValue=$5

apiUrl="${apiBaseUrl}variablegroup/${variableGroupName}/${variableKey}?code=${apiAccessKey}"

curl -X PATCH -H "Content-Type: text/plain" --data "${variableValue}" --url ${apiUrl}