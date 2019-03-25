SCRIPT_ROOT=$(dirname ${BASH_SOURCE})/..

kubectl delete -f ${SCRIPT_ROOT}/deploy/manifests/

kubectl -n custom-metrics delete secret cm-adapter-serving-certs