# `nginx` from nginxinc/kubernetes-ingress

This solution use the nginx ingress controller's implementation from [nginxinc/kubernetes-ingress](https://github.com/nginxinc/kubernetes-ingress/), with some of our changes.

The main difference from the kubernetes's implementation is that doesn't accept `nginx backends` without host. From the other side, we got the metrics working only with this implementation.

## Our changes

The container image of nginx ships also the [songjiayang/nginx-log-exporter](https://github.com/songjiayang/nginx-log-exporter). The log exporter is used to scrape nginx's logs and get response times.

Supervisord as entry point will start both servers.

Metrics of nginx will be available at port `9113`, while the log exporter expose in `4040`. Check `deploy/service/loadbalancer.yaml` for details.

### nginx args

Parameters passed by command line to nginx, are instead specified in the env var `NGINX_ARGS`, that will be read from `supervisord` and passed to `nginx`.

## Setup

Just run `./hack/nginx-up.sh`

## Tear down

Just run './hack/nginx-down.sh`


## Demo application

We will use `azure-vote` app as example. 

There are two ways, one that register a CN record in Azure to have an app host (preferred in our case). The second one that doesn't use a real host, simply tell `curl` how to resolve the fake one.

In both case we need to generate the `tls` certificate and create a secret in Kubernetes

### CN record in DNS

We assume that the DNS name will be `DNSNAME="azure-vote"`. Set it different otherwise.

Set also the public IP of the nginx ingress controller and register the name with:

```bash
export INGRESS_CONTROLLER_IP=......
./hack/public-dns-ip.sh
```

Annotate the output fqdn address and change it in `deploy/ingress/ingress-azure-vote-front.yaml` in the `hosts` item and `host` property of the rule.
Then create the Kubernetes secret. I assume the name of the secret will be `azure-vote-tls`. If you change it, update the ingress file as well.

Add the address in `./hack/create-ingress-tls-secret.sh` and then run it.

Finally you can deploy the ingress file:

```bash
kubectl apply -f deploy/ingress/ingress-azure-vote-front.yaml`
```

Finally query the specified host.

## Without CN entry in DNS

Check [this](https://docs.microsoft.com/en-us/azure/aks/ingress-own-tls) out.
