module "tfstate_storage_account" {
  source = "github.com/schubergphilis/terraform-azure-mcaf-storage-account.git" #TODO: change module source

  name                              = var.storage_account.name
  resource_group_name               = var.resource_group.name
  location                          = var.resource_group.location
  storage_containers                = var.storage_account.storage_containers
  public_network_access_enabled     = var.storage_account.public_network_access_enabled
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
  identity                          = var.storage_account.identity
  ip_rules                          = var.storage_account.ip_rules
  subnet_ids                        = var.storage_account.subnet_ids
  network_bypass                    = var.storage_account.network_bypass
  blob_delete_retention_days        = var.storage_account.blob_delete_retention_days
  container_delete_retention_days   = var.storage_account.container_delete_retention_days
  versioning_enabled                = var.storage_account.versioning_enabled
  change_feed_enabled               = var.storage_account.change_feed_enabled
  contributors                      = var.storage_account.contributors
  allow_nested_items_to_be_public   = var.storage_account.allow_nested_items_to_be_public
  cmk_key_vault_id                  = var.storage_account.cmk_key_vault_id
  cmk_key_name                      = var.storage_account.cmk_key_name
  tags                              = var.tags
}