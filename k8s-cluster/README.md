# k8s with Terraform and AKS

References:
  - [Microsoft](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks)
  - [Terraform](https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform)

## Shared state

Terraform stores the state locally in `.tfstate` files. For multi-person environment (like ours), it's more practile to track the state online on Azure.

### Create a storage account

If you don't have one, create a storage account, then a container where to store the file.

We won't provide any terraform file for this task, since it's just a setup in order to manage the infrastructure more practically.

Firstly, create the resource group:
```bash
az group create --name tfstate-group --location eastus
```

Choose a unique name for the storage account, since the name will be part of the account address, such as:
```bash
an=tfstatestorage$(date '+%Y%m%d')
```

Secondly, create the storage account:
```bash
az storage account create --name $an \
    --resource-group tfstate-group \
    --location eastus \
    --sku Standard_LRS \
    --kind StorageV2
```

Finally, create the container:
```bash
az storage container create -n tfstate-container \
    --account-name $an \
    --account-key $(az storage account keys list \
        --account-name $an \
        --resource-group tfstate-group | grep value | head -1 | cut -d'"' -f4)
```

If need be, you can clean up all by deleting the resource group:
```bash
az group delete --name tfstate-group
```

## Init the cluster

### Choose node size and other variables

Check `variables.tf` to see all the variables. There are [several ways](https://learn.hashicorp.com/terraform/getting-started/variables.html) to overwrite them, 
for example to have a bigger vm for nodes:

```bash
export TF_VAR_vm_size=Standard_B8ms
```

### Steps

Variable `$an` contains the name of storage account.
```bash
an=$(az storage account list --output yaml | grep name -m 1 | cut -f2 -d: | sed 's/ //g')
terraform init \
    -backend-config="storage_account_name=$an" \
    -backend-config="container_name=tfstate-container" \
    -backend-config="access_key=$(az storage account keys list \
        --account-name $an \
        --resource-group tfstate-group | grep value | head -1 | cut -d'"' -f4)" \
    -backend-config="key=k8s.tfstate" 
```

Export service principal:
```bash
export TF_VAR_client_id=$ARM_CLIENT_ID
export TF_VAR_client_secret=$ARM_CLIENT_SECRET
```

Calculate the plan:
```bash
terraform plan -out out.plan
```

Apply the plane:
```bash
terraform apply out.plan
```

## Test the cluster

By applying, Terraform creates the k8s config file in `./azurek8s`. Check whether the configuration is fine, otherwise recreate it with:
```bash
echo "$(terraform output kube_config)" > ./azurek8s
```

Set an environment variable so that kubectl picks up the correct config (consider in saving the current `$KUBECONFIG`).
```bash
export KUBECONFIG="$(pwd)/azurek8s"
```

```bash
kubectl get nodes
```

## Kubernetes dashboard
Run `kubectl proxy` and access to:
  - http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
  - or http://localhost:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

## Destroy the cluster

```bash
terraform destroy
```
