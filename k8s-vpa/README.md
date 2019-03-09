# Vertical Pod Autoscaling

HPA is installed by default (`http://127.0.0.1:8001/apis/autoscaling/`).

For VPA we requires:
  - Kubernetes version >= 1.9
  - `kubectl` connected to cluster
  - [Install Metric server](#metric-server)
  - [Install VPA](#vpa)

## Metric server

Server to collect pod metrics.

## Deploy the server

If the metric server is not deployed by default:

```bash
git clone git@github.com:kubernetes-incubator/metrics-server
cd metrics-server
```

Add the flag to avoid certificates (NOT for production environments), by adding the flag `--kubelet-insecure-tls` to `metrics-server/deploy/1.8+/metrics-server-deployment.yaml`. Edit the file and add the `command` field to the first item of `containers`:
```yaml
# File: ./deploy/1.8+/metrics-server-deployment.yaml
# [...]
       containers:
       - name: metrics-server
         image: k8s.gcr.io/metrics-server-amd64:v0.3.1
         command:
         - /metrics-server
         - --kubelet-insecure-tls
# [...]
```

Then you are ready for:
```bash
kubectl create -f deploy/1.8+/
```

### Test

```bash
kubectl proxy
```

Then open in your browser `http://127.0.0.1:8001/apis/metrics.k8s.io/v1beta1`. If you get `404`, then the setup is failed.

## VPA

Reference [kubernetes/autoscaler/vertical-pod-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)

```bash
git clone https://github.com/lorisrossi/autoscaler
cd */vertical-pod-autoscaler
./hack/vpa-up.sh
```

### Test

Test at `http://127.0.0.1:8001/apis/autoscaling.k8s.io/v1beta1` and check whether components are running:
```bash
kubectl --namespace=kube-system get pods|grep vpa
```

```
vpa-admission-controller-6b758d8678-mfpjj   1/1     Running   0          12m
vpa-recommender-5dfc7669f7-242ff            1/1     Running   0          12m
vpa-updater-5d596b7897-xm46l                1/1     Running   0          12m
```

### Deploy a vpa configuration for a pod

- Prepare the locust VM as described in folder `locust`.
- Deploy the app example: `kubectl create -f azure-vote.yaml` (From root of the repo).
- Deploy the vpa, for example for the frontend of azure-vote: `kubectl create -f azure-vote-vpa.yaml` (From `vpa` folder).
- Start the locust test.
- Monitor the resources, should vertically autoscale (maybe deploying the ui could help, seems terraform doesn't deploy it by default).
