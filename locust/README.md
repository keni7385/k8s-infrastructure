# Load tests

We use [locust.io](https://www.locust.io/) to do load testing on services.

# Setup

`python3` and `PyPi` required.

Install locust:

```bash
pip install locustio
```

## Start a test

Start the webui:

``` bash
locust -f locustfile.py -H https://ADDRESS
```

Start headless:

``` bash
locust -f locustfile.py -H https://ADDRESS -c NUM_CLIENTS -r HATCH_RATE --no-web
```

## Start the VM with locust

To start a virtual machine with locust already installed, ready to be launched.

### Build image with Packer

```bash
source ../ids.sh
```

```bash
packer validate builder.json
```

```bash
packer build builder.json | tee packer_output.txt
```

### Provision the VM with Terraform

You should already have the VM image built, so you can start provisioning the VM.

```bash
source ../ids.sh
```

Firstly initialise Terraform, to download possible plugins and validate your files:

```bash
terraform init
```

Then you can see an execution plan with the changes that will be applied to your infrastructure:

```bash
terraform plan
```

Then, if there are changes, apply them with:

```bash
terraform apply
```

Once changes have been applied, you can login to the VM:

```bash
ssh azureuser@$(terraform output locustvm_public_ip) [-i ~/.ssh/azure_vm]
```

### Tear down the VM

```bash
terraform destroy
```
