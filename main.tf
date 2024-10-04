data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group.name
  location = var.resource_group.location
  tags = merge(
    try(var.tags),
    tomap({
      "Resource Type" = "Resource Group"
    })
  )
}

resource "azurerm_storage_account" "this" {
  resource_group_name               = azurerm_resource_group.this.name
  location                          = azurerm_resource_group.this.location
  name                              = var.storage_account.name
  account_tier                      = var.storage_account.account_tier
  account_replication_type          = var.storage_account.account_replication_type
  account_kind                      = var.storage_account.account_kind
  access_tier                       = var.storage_account.access_tier
  shared_access_key_enabled         = var.storage_account.shared_access_key_enabled
  https_traffic_only_enabled        = var.storage_account.https_traffic_only_enabled
  min_tls_version                   = var.storage_account.min_tls_version
  default_to_oauth_authentication   = var.storage_account.default_to_oauth_authentication
  infrastructure_encryption_enabled = var.storage_account.infrastructure_encryption_enabled
  sftp_enabled                      = var.storage_account.sftp_enabled
  allow_nested_items_to_be_public   = var.storage_account.allow_nested_items_to_be_public

  blob_properties {
    delete_retention_policy {
      days = var.storage_account.blob_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.storage_account.container_delete_retention_days
    }
    versioning_enabled  = var.storage_account.versioning_enabled
    change_feed_enabled = var.storage_account.change_feed_enabled
  }

  dynamic "identity" {
    for_each = var.storage_account.identity ? [true] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = merge(
    try(var.tags),
    tomap({
      "Resource Type" = "Storage Account"
    })
  )

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}

resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id = azurerm_storage_account.this.id

  default_action             = length(var.storage_account.ip_rules) == 0 && length(var.storage_account.subnet_id) == 0 ? "Allow" : "Deny"
  ip_rules                   = var.storage_account.ip_rules
  virtual_network_subnet_ids = var.storage_account.subnet_id
  bypass                     = var.storage_account.network_bypass
}

resource "azurerm_storage_container" "this" {
  name                  = "ccoetfstate"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "extra" {
  for_each = var.storage_account.contributors

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

resource "azurerm_storage_account_customer_managed_key" "this" {
  count = local.cmk

  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = var.storage_account.cmk_key_vault_id
  key_name           = var.storage_account.cmk_key_vault_keyname

  depends_on = [
    azurerm_role_assignment.cmk
  ]
}

resource "azurerm_role_assignment" "cmk" {
  count = local.cmk

  scope                = var.storage_account.cmk_key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.this.identity[0].principal_id

  depends_on = [azurerm_storage_account.this]
}

resource "azurerm_network_security_rule" "allow_https_out_to_azdevops" {
  name                         = "allow_https_out_to_azdevops"
  priority                     = 105
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefix        = "VirtualNetwork"
  destination_address_prefixes = var.destination_address_prefixes
  resource_group_name          = var.network_security_group_rsg
  network_security_group_name  = var.network_security_group_name
}
