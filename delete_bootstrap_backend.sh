#!/bin/bash

read -e -i westeurope -p "Azure region        : " location
read -e -i terraform  -p "resource group name : " resource_group_name
read -e -i tfstate    -p "container name      : " container_name

location=${location:-norwayeast}
resource_group_name=${resource_group_name:-terraform}
container_name=${container_name:-tfstate}


# Check to see if existing storage account exists
jmespath_query="[? tags.created_by == 'bootstrap_backend.sh']|[0].name"
# https://stackoverflow.com/questions/20185095/remove-0d-from-variable-in-bash
storage_account_name=$(az storage account list --resource-group $resource_group_name --query "$jmespath_query" --output tsv | tr -d '\r')


if [ -n "$storage_account_name" ]
then
  echo "Found existing storage account $storage_account_name in $resource_group_name. DELETING IT."
  az storage account delete --name $storage_account_name --resource-group $resource_group_name
else
  echo "Did not find existing storage account $storage_account_name in $resource_group_name."
fi

echo "Found existing resource group $resource_group_name. DELETING IT."
az group delete --name $resource_group_name


echo "Found files. DELETING IT."
rm -rf ./bootstrap_backend.tf
rm -rf ./bootstrap_backend.auto.tfvars
rm -rf .terraform
rm -rf .terraform.lock.hcl
