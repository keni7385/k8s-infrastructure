SCRIPT_ROOT=$(dirname ${BASH_SOURCE})/..

kubectl delete -f ${SCRIPT_ROOT}/deploy/service/loadbalancer.yaml
kubectl delete -f ${SCRIPT_ROOT}/deploy/deployment/nginx-ingress.yaml

kubectl delete -f ${SCRIPT_ROOT}/deploy/rbac/rbac.yaml

kubectl delete -f ${SCRIPT_ROOT}/deploy/common/nginx-config.yaml
kubectl delete -f ${SCRIPT_ROOT}/deploy/common/default-server-secret.yaml
