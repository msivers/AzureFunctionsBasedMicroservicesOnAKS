#!/bin/bash
eval "$(jq -r '@sh "export CERT=\(.cert)"')"
if [[ -z "${CERT}" ]]; then export CERT=none; fi

eval "$(jq -r '@sh "export KEY=\(.key)"')"
if [[ -z "${KEY}" ]]; then export KEY=none; fi

echo $CERT | base64 -d > revplat_nopwd.pfx

result1=$(openssl pkcs12 -in revplat_nopwd.pfx -passin "pass:" -clcerts -nokeys -out revplat.crt -passout "pass:$KEY" 2>&1)
result2=$(openssl pkcs12 -in revplat_nopwd.pfx -passin "pass:" -nocerts -out revplat.key -passout "pass:$KEY" 2>&1)
result3=$(openssl rsa -in revplat.key -passin "pass:$KEY" -out revplat.unencrypted.key 2>&1)

crt=$(jq -aRs . <<< cat revplat.crt)
key=$(jq -aRs . <<< cat revplat.unencrypted.key)

echo { \"crt\":$crt, \"key\":$key } | jq .