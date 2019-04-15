SCRIPT_ROOT=$(dirname ${BASH_SOURCE})/..

kubectl create -f ${SCRIPT_ROOT}/deploy/prom-operator.yaml
kubectl create -f ${SCRIPT_ROOT}/deploy/rbac-prometheus-pods.yaml
kubectl create -f ${SCRIPT_ROOT}/monitoring-nginx/prometheus-nginx-ingress.yaml
kubectl create -f ${SCRIPT_ROOT}/monitoring-nginx/servicemonitor-nginx-ingress.yaml
kubectl create -f ${SCRIPT_ROOT}/deploy/service-prometheus-nginx.yaml
