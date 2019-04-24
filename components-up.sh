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


# Ready to up stuff
header "Pwitter up"
kubectl create -f pwitter.yaml

header "Nginx ingress up"
./nginx-ingress-github/hack/nginx-up.sh

header "Pwitter ingress and CN record"

# wait for external ip in nginx-ingress controller
external_ip=""
while [ -z $external_ip ]; do
  echo "Waiting for nginx-ingress's end point..."
  external_ip=$(kubectl get svc nginx-ingress -n nginx-ingress --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$external_ip" ] && sleep 10
done

echo -e '${GREEN}${bold}nginx-ingress end point ready:' && echo $external_ip && echo -e "${NC}${normal}"
INGRESS_CONTROLLER_IP="$external_ip" DNSNAME=pwitter ./nginx-ingress-github/hack/public-dns-ip.sh
ADDR=pwitter.eastus.cloudapp.azure.com NAME=pwitter-tls ./nginx-ingress-github/hack/create-ingress-tls-secret.sh
kubectl apply -f nginx-ingress-github/deploy/ingress/ingress-pwitter-front.yaml

header "Test pwitter DNS"
set -o xtrace
curl https://pwitter.eastus.cloudapp.azure.com/pweets -k
curl -X POST https://pwitter.eastus.cloudapp.azure.com/pweets -d 'user="Mario Bianchi"&body="There are several unsolved problems in Computer science"' -k
curl https://pwitter.eastus.cloudapp.azure.com/pweets -k
set +o xtrace

header "Prometheus up"
./prometheus/hack/prometheus-up.sh
kubectl create -f prometheus/monitoring-nginx/prometheus-nginx-ingress.yaml 

header "Prometheus adapter up"
./prometheus/adapter/hack/adapter-up.sh 

header "VPA up"
./k8s-vpa/autoscaler/vertical-pod-autoscaler/hack/vpa-up.sh

header "Creating VPA object for pwitter"
printf "Give you time to open logs..."
read -p "Press enter to continue"
kubectl create -f k8s-vpa/pwitter-vpa.yaml

header "Setup finished"
