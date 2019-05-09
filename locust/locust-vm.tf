provider "azurerm" {
  version = "~>1.5"
}

resource "azurerm_resource_group" "locustgroup" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags {
    environment = "Terraform Locust"
  }
}

resource "azurerm_virtual_network" "locustnetwork" {
  name                = "locust-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.locustgroup.location}"
  resource_group_name = "${azurerm_resource_group.locustgroup.name}"

  tags {
    environment = "Terraform Locust"
  }
}

resource "azurerm_subnet" "locustsubnet" {
  name                 = "locust-subnet"
  resource_group_name  = "${azurerm_resource_group.locustgroup.name}"
  virtual_network_name = "${azurerm_virtual_network.locustnetwork.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "locustpublicip" {
  name                = "locust-public-IP"
  location            = "${azurerm_resource_group.locustgroup.location}"
  resource_group_name = "${azurerm_resource_group.locustgroup.name}"
  allocation_method   = "Dynamic"

  tags {
    environment = "Terraform Locust"
  }
}

resource "azurerm_network_security_group" "locustnsg" {
  name                = "locust-network-security-group"
  location            = "${azurerm_resource_group.locustgroup.location}"
  resource_group_name = "${azurerm_resource_group.locustgroup.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Terraform Locust"
  }
}

resource "azurerm_network_interface" "locustnic" {
  name                      = "locust-NIC"
  location                  = "${azurerm_resource_group.locustgroup.location}"
  resource_group_name       = "${azurerm_resource_group.locustgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.locustnsg.id}"

  ip_configuration {
    name                          = "locust-nic-configuration"
    subnet_id                     = "${azurerm_subnet.locustsubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.locustpublicip.id}"
  }

  tags {
    environment = "Terraform Locust"
  }
}

data "azurerm_resource_group" "locustimagegroup" {
  name = "${var.image_resource_group_name}"
}

data "azurerm_image" "locustimage" {
  name                = "${var.image_name}"
  resource_group_name = "${data.azurerm_resource_group.locustimagegroup.name}"
}

resource "azurerm_virtual_machine" "locustvm" {
  name                  = "locust-VM"
  location              = "${azurerm_resource_group.locustgroup.location}"
  resource_group_name   = "${azurerm_resource_group.locustgroup.name}"
  network_interface_ids = ["${azurerm_network_interface.locustnic.id}"]
  vm_size               = "Standard_F16s"

  storage_os_disk {
    name              = "locust-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    id="${data.azurerm_image.locustimage.id}"
  }

  os_profile {
    computer_name  = "locustvm"
    admin_username = "${var.locustvm_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  tags {
    environment = "Terraform Locust"
  }
}

data "azurerm_public_ip" "locustpublicip" {
  name                = "${azurerm_public_ip.locustpublicip.name}"
  resource_group_name = "${azurerm_virtual_machine.locustvm.resource_group_name}"
}
