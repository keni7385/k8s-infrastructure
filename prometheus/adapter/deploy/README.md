Example Deployment
==================

1. Make sure you've built the included Dockerfile with `make docker-build`. The image should be tagged as `directxman12/k8s-prometheus-adapter:latest`.

2. `kubectl create namespace custom-metrics` to ensure that the namespace that we're installing
   the custom metrics adapter in exists.

3. Create a secret called `cm-adapter-serving-certs` with two values:
   `serving.crt` and `serving.key`. These are the serving certificates used
   by the adapter for serving HTTPS traffic.  For more information on how to
   generate these certificates, see the [auth concepts
   documentation](https://github.com/kubernetes-incubator/apiserver-builder/blob/master/docs/concepts/auth.md)
   in the apiserver-builder repository.
   The kube-prometheus project published two scripts [gencerts.sh](https://github.com/coreos/prometheus-operator/blob/master/contrib/kube-prometheus/experimental/custom-metrics-api/gencerts.sh)
   and [deploy.sh](https://github.com/coreos/prometheus-operator/blob/master/contrib/kube-prometheus/experimental/custom-metrics-api/deploy.sh) to create the `cm-adapter-serving-certs` secret.

```bash
export PURPOSE=serving
openssl req -x509 -sha256 -new -nodes -days 365 -newkey rsa:2048 -keyout ${PURPOSE}-ca.key -out ${PURPOSE}-ca.crt -subj "/CN=ca"
echo '{"signing":{"default":{"expiry":"43800h","usages":["signing","key encipherment","'${PURPOSE}'"]}}}' > "${PURPOSE}-ca-config.json"
kubectl -n custom-metrics create secret tls cm-adapter-serving-certs --cert=./serving-ca.crt --key=./serving-ca.key
rm serving-ca-config.json serving-ca.crt serving-ca.key
```

Edit file `manifests/custom-metrics-apiserver-deployment.yaml`, assign:
```yaml
- --tls-cert-file=/var/run/serving-cert/tls.crt
- --tls-private-key-file=/var/run/serving-cert/tls.key
```

4. `kubectl create -f manifests/`, modifying the Deployment as necessary to
   point to your Prometheus server, and the ConfigMap to contain your desired
   metrics discovery configuration.
