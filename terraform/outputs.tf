output "vm_public_ip" {
  value = azurerm_public_ip.example.ip_address
}

output "vm_private_ip" {
  value = azurerm_network_interface.example.private_ip_address
}

output "admin_username" {
  value = azurerm_linux_virtual_machine.example.admin_username
}