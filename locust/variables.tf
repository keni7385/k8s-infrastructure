variable "image_resource_group_name" {
  description = "The resource group name of VM image"
  default     = "locust_group"
}

variable "image_name" {
  description = "The image name to install in the VM disk"
  default     = "LocustImage"
}

variable "resource_group_name" {
  description = "The locust resource group name"
  default     = "locust_group"
}

variable "resource_group_location" {
  description = "The location for all locust infrustructure"
  default     = "East US"
}

variable "ssh_public_key" {
  description = "Path to the ssh public key to deploy on the locust VM"
  default     = "~/.ssh/azure_vm.pub"
}

variable "locustvm_user" {
  description = "The account's username to log in to the VM"
  default     = "azureuser"
}
