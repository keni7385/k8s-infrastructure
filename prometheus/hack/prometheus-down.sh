SCRIPT_ROOT=$(dirname ${BASH_SOURCE})/..

kubectl delete -f ${SCRIPT_ROOT}/deploy/prom-operator.yaml
kubectl delete -f ${SCRIPT_ROOT}/deploy/rbac-prometheus-pods.yaml
kubectl delete -f ${SCRIPT_ROOT}/monitoring-nginx/prometheus-nginx-ingress.yaml
kubectl delete -f ${SCRIPT_ROOT}/monitoring-nginx/servicemonitor-nginx-ingress.yaml
kubectl delete -f ${SCRIPT_ROOT}/deploy/service-prometheus-nginx.yaml
