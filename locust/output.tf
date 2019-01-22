output "locustvm_public_ip" {
    value = "${data.azurerm_public_ip.locustpublicip.ip_address}"
}
