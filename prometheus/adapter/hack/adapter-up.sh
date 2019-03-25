kubectl create namespace custom-metrics

# create certificates
export PURPOSE=serving
openssl req -x509 -sha256 -new -nodes -days 365 -newkey rsa:2048 -keyout ${PURPOSE}-ca.key -out ${PURPOSE}-ca.crt -subj "/CN=ca"
echo '{"signing":{"default":{"expiry":"43800h","usages":["signing","key encipherment","'${PURPOSE}'"]}}}' > "${PURPOSE}-ca-config.json"
kubectl -n custom-metrics create secret tls cm-adapter-serving-certs --cert=./serving-ca.crt --key=./serving-ca.key
rm serving-ca-config.json serving-ca.crt serving-ca.key

kubectl create -f ../deploy/manifests/