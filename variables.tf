variable "resource_group" {
  description = "The name of the resource group in which to create the resources."
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = null
    location = null
  }
}

variable "storage_account" {
  type = object({
    name                              = string
    account_tier                      = optional(string, "Standard")
    account_replication_type          = optional(string, "GRS")
    account_kind                      = optional(string, "StorageV2")
    access_tier                       = optional(string, "Hot")
    shared_access_key_enabled         = optional(bool, false)
    https_traffic_only_enabled        = optional(bool, true)
    min_tls_version                   = optional(string, "TLS1_2")
    default_to_oauth_authentication   = optional(bool, true)
    infrastructure_encryption_enabled = optional(bool, true)
    sftp_enabled                      = optional(bool, false)
    identity                          = optional(bool, true)
    ip_rules                          = optional(list(string), [])
    subnet_id                         = optional(list(string), [])
    network_bypass                    = optional(set(string), ["None"])
    blob_delete_retention_days        = optional(number, 30)
    container_delete_retention_days   = optional(number, 30)
    versioning_enabled                = optional(bool, true)
    change_feed_enabled               = optional(bool, true)
    contributors                      = optional(set(string), [])
    allow_nested_items_to_be_public   = optional(bool, false)
    cmk_key_vault_id                  = optional(string, 0)
    cmk_key_vault_keyname             = optional(string, 0)
  })
  description = <<STORAGE_ACCOUNT_DETAILS
This object describes the configuration for an Azure Storage Account.

- `name`                              = (Required) - The name of the storage account.
- `account_tier`                      = (Optional) - The Tier to use for this storage account. Valid options are Standard and Premium. Defaults to Standard.
- `account_replication_type`          = (Optional) - The type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, and RA_GZRS. Defaults to GRS.
- `account_kind`                      = (Optional) - The Kind of account to create. Valid options are Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage, and StorageV2. Defaults to StorageV2.
- `access_tier`                       = (Optional) - The access tier for the storage account. Valid options are Hot and Cool. Defaults to Hot.
- `shared_access_key_enabled`         = (Optional) - Allow or disallow shared access keys for this storage account. Defaults to false.
- `https_traffic_only_enabled`        = (Optional) - Allow or disallow only HTTPS traffic to this storage account. Defaults to true.
- `min_tls_version`                   = (Optional) - The minimum TLS version to allow for requests to this storage account. Valid options are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2.
- `public_network_access_enabled`     = (Optional) - Allow or disallow public network access to this storage account. Defaults to false.
- `default_to_oauth_authentication`   = (Optional) - Allow or disallow defaulting to OAuth authentication for this storage account. Defaults to true.
- `infrastructure_encryption_enabled` = (Optional) - Allow or disallow infrastructure encryption for this storage account. Defaults to true.
- `sftp_enabled`                      = (Optional) - Allow or disallow SFTP access to this storage account. Defaults to false.
- `identity`                          = (Optional) - Enable or disable the system-assigned managed identity for this storage account. Defaults to true.
- `ip_rules`                          = (Optional) - A list of IP addresses that are allowed to access this storage account. Defaults to an empty list.
- `subnet_id`                         = (Optional) - A list of subnet IDs that are allowed to access this storage account. Defaults to an empty list.
- `network_bypass`                    = (Optional) - A list of services that are allowed to bypass the network rules. Defaults to [] but could be any of ["Logging", "Metrics", "AzureServices", "None"].
- `blob_delete_retention_days`        = (Optional) - The number of days to retain deleted blobs for. Defaults to 90.
- `container_delete_retention_days`   = (Optional) - The number of days to retain deleted containers for. Defaults to 90.
- `versioning_enabled`                = (Optional) - Enable or disable versioning for this storage account. Defaults to true.
- `change_feed_enabled`               = (Optional) - Enable or disable the change feed for this storage account. Defaults to true.
- `contributors`                      = (Optional) - A list of principal IDs that are allowed to be contributor on this storage account. Defaults to an empty list.
- `allow_nested_items_to_be_public`   = (Optional) - Allow or disallow nested items to be public. Defaults to false.
- `key_vault_id`                       = (Optional) - The ID of the Key Vault to
- `key_vault_keyname`                  = (Optional) - The name of the Key Vault key to use for encryption.

  Example Inputs:

```hcl
module "azure-devops" "this" {
  name                              = "storageaccountname"
  ip_rules                          = [ "1.2.3.4" ]
  subnet_id                         = [ "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rgname/providers/Microsoft.Network/virtualNetworks/vnetname/subnets/subnetname" ]

  contributors = [
    "0b9fe8e2-09cb-1234-1243-671f5b1b29fd"
  ]
}

```
STORAGE_ACCOUNT_DETAILS
  nullable    = false
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "zones" {
  type        = list(string)
  default     = []
  description = "A list of availability zones in which the resource should be created."
}

