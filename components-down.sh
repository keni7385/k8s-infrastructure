#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)

function header {
    printf "${GREEN}---[${bold} $1 ${normal}${GREEN}]---${NC}\n"
}

function error {
    printf "${RED}///${bold} Error ${normal}${RED}///\n"
    printf "  $1\n"
    printf "/////////////${NC}\n"
}

function checkLastCmd {
    if [ $? != "0" ];
    then
        error "$1"
        exit 1
    fi
}

function checkEnvVar {
    if [[ -z "${!1}" ]]; then
        error "Env var $1 not set."
        exit 1
    fi
}

header "kubectl nodes"
kubectl get nodes
checkLastCmd "Kubectl not connected to any cluster"

# check az, reuqired to create CN record
which az
checkLastCmd "Cannot find az, the azure client program."

# Check some variables needed from az
checkEnvVar "ARM_CLIENT_ID"
checkEnvVar "ARM_CLIENT_SECRET"
checkEnvVar "ARM_SUBSCRIPTION_ID"
checkEnvVar "ARM_TENANT_ID"


# Ready to down stuff
header "Deleting VPA object for pwitter"
kubectl delete -f k8s-vpa/pwitter-vpa.yaml

header "VPA down"
./k8s-vpa/autoscaler/vertical-pod-autoscaler/hack/vpa-down.sh

header "Prometheus adapter down"
./prometheus/adapter/hack/adapter-down.sh 

header "Prometheus down"
./prometheus/hack/prometheus-down.sh

header "Deleting pwitter ingress and CN record"
kubectl delete -f nginx-ingress-github/deploy/ingress/ingress-pwitter-front.yaml
rm pwitter-tls.crt pwitter-tls.key
kubectl delete secret tls pwitter-tls 

header "Nginx ingress down"
./nginx-ingress-github/hack/nginx-down.sh

header "Pwitter down"
kubectl delete -f pwitter.yaml

header "Finished, everything is down"
