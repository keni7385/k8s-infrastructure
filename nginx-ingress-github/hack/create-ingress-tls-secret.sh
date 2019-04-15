#!/bin/bash

if [[ -z "${NAME}" ]]; then
   NAME=azure-vote-tls
   echo 
fi

if [[ -z "${ADDR}" ]]; then
   ADDR=azure-vote.eastus.cloudapp.azure.com
   echo "Defaul tls cert ADDR=${ADDR}"
fi

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out "$NAME.crt" \
    -keyout "$NAME.key" \
    -subj "/CN=$ADDR/O=$NAME"

kubectl create secret tls ${NAME} --cert=./${NAME}.crt --key=./${NAME}.key
