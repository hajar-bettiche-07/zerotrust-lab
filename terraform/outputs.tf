output "vm_public_ip" {
    description = " IP IP publique de la VM pour SSH "
    value       = azurerm_public_ip.pip.ip_address
}