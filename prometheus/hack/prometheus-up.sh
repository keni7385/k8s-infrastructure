SCRIPT_ROOT=$(dirname ${BASH_SOURCE})/..

kubectl create -f ${SCRIPT_ROOT}/deploy/prom-operator.yaml

# kubectl create -f ${SCRIPT_ROOT}/deploy/deployment-example-app.yaml
# kubectl create -f ${SCRIPT_ROOT}/deploy/service-example-app.yaml
# kubectl create -f ${SCRIPT_ROOT}/deploy/servicemonitor-example-app.yaml
# kubectl create -f ${SCRIPT_ROOT}/deploy/sample-app.deploy.yaml
# kubectl create -f ${SCRIPT_ROOT}/deploy/servicemonitor-sample-app.yaml

kubectl create -f ${SCRIPT_ROOT}/deploy/rbac-prometheus-pods.yaml
kubectl create -f ${SCRIPT_ROOT}/monitoring-nginx/prometheus-nginx-ingress.yaml
kubectl create -f ${SCRIPT_ROOT}/monitoring-nginx/servicemonitor-nginx-ingress.yaml
kubectl create -f ${SCRIPT_ROOT}/deploy/service-prometheus-nginx.yaml

