#!/bin/bash

# ============================
# DOWNLOAD AND UNZIP TERRAFORM
# ============================

uname="$(uname -s)"

# For macOS
if [ "$(uname)" == "Darwin" ]; then
    terraformLink="https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_darwin_amd64.zip"
    echo "Downloading Terraform for macOS"
# For Linux
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    terraformLink="https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip"
    echo "Downloading Terraform for Linux"
fi

curl -o terraform.zip ${terraformLink}
echo "Terraform downloaded"

unzip -o terraform.zip
echo "Terraform extracted"