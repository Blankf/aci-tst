output "storage_account_id" {
  value = module.tfstate_storage_account.id
}

output "storage_account_name" {
  value = module.tfstate_storage_account.name
}

output "storage_account_identity" {
  value = var.storage_account.identity ? module.tfstate_storage_account.identity[0].principal_id : null
}

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