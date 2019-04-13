# Ingress

CANNATO, addon-http-application-routing is actually an nginx-ingress

## Installing a Ingress Controller

We chose `nginx-controller`.

The following command is required for all deployments:

```bash
kubectl apply -f mandatory.yaml
```

Second one, specific for Azure:

```bash
kubectl apply -f cloud-generic.yaml
```

## Verify installation

```bash
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch
```

You should see the `nginx-ingress-controller` running.

To check the version you are running:
```bash
POD_NAMESPACE=ingress-nginx
POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version
```

## Create a Load Balancer

### Toy apps

In order to create a Load Balancer with Ingress and `nginx-controller`, we will use two deployments examples and their services:

```bash
kubectl create -f app-deployment.yaml -f app-service.yaml
```

The services created from `app-service.yaml` are by default `type=ClusterIp`, so not accessible from external clients.


### Ingress rules

We will need 3 `Ingress` resources, one for the load balancer (shared by the two apps) and two for the apps (one for each of them):

```bash
kubectl create -f nginx-ingress.yaml -n=ingress-nginx
kubectl create -f app-ingress.yaml
```

Remember to add the following annotation to ingresses:
```yaml
annotations:
  kubernetes.io/ingress.class: nginx
```

Last step is to expose the load balancer for externale access:

```bash
kubectl create -f nginx-ingress-controller-service.yaml -n=ingress-nginx
```

## Addon HTTP routing

(Just as reference) Is an ingress controller based on nginx  provided from Azure. It can help to espose easier services throught an host name.

This is an alternative to install `nginx` directly, but didn't work in our case, since we cannot modify the configurations and parameters.

### Enable `http_application_routing`

```bash
az aks enable-addons --resource-group k8sClusterGroup --name k8s-cluster --addons http_application_routing
```

Retrieve the DNS zone name:

```bash
 az aks show --resource-group k8sClusterGroup --name k8s-cluster --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
```

If with previous command the host retrivede is `HOST_RETRIEVED`, then set the host in the ingress file as `name.HOST_RETRIEVED`. In addition, set the class of nginx to `addon-http-application-routing` with the annotation:

```yaml
annotations:
  kubernetes.io/ingress.class: addon-http-application-routing
```

### Disabling Addon HTTP routing

```bash
az aks disable-addons --addons http_application_routing --resource-group k8sClusterGroup --name k8s-cluster --no-wait
```

Remove some resources that left around. Look for `addon-http-application-routing` resources in:

```bash
kubectl get deployments --namespace kube-system
kubectl get services --namespace kube-system
kubectl get configmaps --namespace kube-system
kubectl get secrets --namespace kube-system
```
