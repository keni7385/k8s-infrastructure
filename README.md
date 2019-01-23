# k8s-infrastructure

Repository for k8s configuration files.

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
