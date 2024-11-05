output "azure_container_registry_id" {
  value = azurerm_container_registry.this.id
}

output "azure_container_registry_name" {
  value = azurerm_container_registry.this.name
}

output "azure_container_registry_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "azure_container_registry_admin_username" {
  value = azurerm_container_registry.this.admin_username
}

output "azure_container_registry_admin_password" {
  value = azurerm_container_registry.this.admin_password
}