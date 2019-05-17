# k8s-infrastructure

This repository contains the source code of our research project. Additional repositories for patched components can be find at:

  - Modified version of the Pod Autoscaler: [https://github.com/lorisrossi/autoscaler]()
  - Modified version of Nginx Ingress Controller implementation: [https://github.com/keni7385/kubernetes-ingress]() <br> In which we added the modified version of the Prometheus Nginx Log Exporter: [https://github.com/keni7385/prometheus-nginxlog-exporter]()

Commands listed here are for the Azure CLI `az`, but all the file and configurations are cloud-indipendent.

## Service principal

Service principals are separate identities that can be associated with an account. Service principals are useful for working with applications and tasks that must be automated.

Useful commands:

  - Create the service principal (the password is created for you):
    ```bash
    az ad sp create-for-rbac --name ServicePrincipalName
    ```
    Output example:
    ```
    {
      "appId": "clientid-____-____-____-____________",
      "displayName": "ServicePrincipalName",
      "name": "http://ServicePrincipalName",
      "password": "xxxxxxxx-xxxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "tenant": "yourtena-ntid-____-____-____________"
    }
    ```
[More information and role assignments.](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest)

## API setup

Create the file `ids.sh` with:

``` bash
echo "export ARM_CLIENT_ID=0\n"\
     "export ARM_CLIENT_SECRET=0\n"\
     "export ARM_SUBSCRIPTION_ID=0\n"\
     "export ARM_TENANT_ID=0" > ids.sh
```
(updates of this file are ignored)

Replace `ARM_CLIENT_ID` with `appId` from the previous command (or use exhisting ones if you already have a service principal), `ARM_CLIENT_SECRET` with `password`, `TENANT_ID` with your `tenant` (you can get it also from `az account show`).

Set the `ARM_SUBSCRIPTION_ID` with one of your available subscriptions. You can see your subscriptions:

``` bash
az account list --output table
```

```
Name               CloudName    SubscriptionId                        State    IsDefault
-----------------  -----------  ------------------------------------  -------  -----------
kub                AzureCloud   11111111-1111-1111-1111-111111111111  Enabled  True
Microsoft Imagine  AzureCloud   22222222-2222-2222-2222-222222222222  Enabled  False
```

## Run the components

There are several components for this project.
After [creating the cluster](\k8s-cluster\README.md), you can start all of them by:

```bash
./components-up.sh
```

And stop them with:

```bash
./components-down.sh
```
