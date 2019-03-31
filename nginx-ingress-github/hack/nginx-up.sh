SCRIPT_ROOT=$(dirname ${BASH_SOURCE})/..

kubectl apply -f ${SCRIPT_ROOT}/deploy/common/ns-and-sa.yaml
kubectl apply -f ${SCRIPT_ROOT}/deploy/common/default-server-secret.yaml
kubectl apply -f ${SCRIPT_ROOT}/deploy/common/nginx-config.yaml

# check cluster admin role is up before this
kubectl apply -f ${SCRIPT_ROOT}/deploy/rbac/rbac.yaml

kubectl apply -f ${SCRIPT_ROOT}/deploy/deployment/nginx-ingress.yaml
kubectl apply -f ${SCRIPT_ROOT}/deploy/service/loadbalancer.yaml
