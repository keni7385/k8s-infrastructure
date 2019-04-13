#!/bin/bash

# Set the ingress controller ip in var INGRESS_CONTROLLER_IP
# Set the name to associate with public IP address in var DNSNAME


if [[ -z "${INGRESS_CONTROLLER_IP}" ]]; then
  echo "Set Ingress controller ip in env var INGRESS_CONTROLLER_IP"
  exit 1;
fi

if [[ -z "${DNSNAME}" ]]; then
  DNSNAME="azure-vote"
  echo "By default DNSNAME=\"azure-vote\""
fi

# Get the resource-id of the public ip
PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$INGRESS_CONTROLLER_IP')].[id]" --output tsv)

# Update public ip address with DNS name
az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME
