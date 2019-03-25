# Ingress by Microsoft Guide

Reference: https://docs.microsoft.com/en-us/azure/aks/ingress-tls

## Helm

The tutorial use [`helm`](https://github.com/helm/helm). `helm` needs to be installed on your machine from where you access to `kubectl` and on your cluster (by adding the `tiller` component).

On Azure, AKS has no `cluster-admin` role by default, so we need to add it:
```bash
kubectl create -f cluster-admin-role.yaml
```

After you installed on your machine, deploy the `helm`'s service account:

```bash
kubectl apply -f helm-rbac.yaml
```

Then install `helm` on your cluster:

```bash
helm init --service-account tiller
```

Finally patch the `tiller`'s deployment:

```bash
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

By doing `helm version`, you should see something similar to:

```
Client: &version.Version{SemVer:"v2.13.0", GitCommit:"79d07943b03aea2b76c12644b4b54733bc5958d6", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.13.0", GitCommit:"79d07943b03aea2b76c12644b4b54733bc5958d6", GitTreeState:"clean"}
```

*Warning*: don't use this setup in production, check the official documentation for that.

## Install the Ingress controller

```bash
helm install stable/nginx-ingress --namespace kube-system --set controller.replicaCount=2
```

Verify with:

```bash
kubectl get service -l app=nginx-ingress --namespace kube-system
```

## Demo

We will use two apps at the same time:

```bash
helm repo add azure-samples https://azure-samples.github.io/helm-charts/
helm install azure-samples/aks-helloworld
helm install azure-samples/aks-helloworld --set title="AKS Ingress Demo" --set serviceName="ingress-demo"
```

Create their ingress:

```bash
kubectl apply -f hello-world-ingress.yaml
```

## Troubleshooting

`Helm` has many problems on AKS. Especially for the installation part.

If you want to remove it to try a new fresh installation, normally you should run:

```bash
helm reset
```

Or `helm init --upgrade` to overwrite. But it doesn't always work, so you can delete `helm` manually:

```bash
kubectl delete deployment tiller-deploy -n kube-system
kubectl delete service tiller-deploy -n kube-system
```

### Cluster role problems

If installing `stable/ingress-nginx` chart doesn't work, try also the following other commands in [this thread](https://github.com/helm/helm/issues/3055) or check a [stackoverflow post](https://stackoverflow.com/questions/50309012/deploy-nginx-ingress-in-aks-without-rbac-issue).
