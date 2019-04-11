# Ingress

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

## Enable `http_application_routing`

```bash
az aks enable-addons --resource-group k8sClusterGroup --name k8s-cluster --addons http_application_routing
```

Retrieve the DNS zone name:

```bash
 az aks show --resource-group k8sClusterGroup --name k8s-cluster --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
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
  kubernetes.io/ingress.class: addon-http-application-routing
```

Last step is to expose the load balancer for externale access:

```bash
kubectl create -f nginx-ingress-controller-service.yaml -n=ingress-nginx
```
