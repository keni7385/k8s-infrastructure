variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 3
}

variable "vm_size" {
    default = "Standard_DS1_v2"
}

variable "ssh_public_key" {
    default = "~/.ssh/azure_vm.pub"
}

variable "dns_prefix" {
    default = "k8s-prefix"
}

variable cluster_name {
    default = "k8s-cluster"
}

variable resource_group_name {
    default = "k8sClusterGroup"
}

variable location {
    default = "East US"
}

variable k8scluster_user {
    default = "azureuser"
}
