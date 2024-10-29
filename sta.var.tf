variable "storage_account" {
  type = object({
    name                              = string
    resource_group_name               = string
    location                          = string
    public_network_access_enabled     = optional(bool, false)
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
    subnet_ids                        = optional(list(string), [])
    network_bypass                    = optional(set(string), ["None"])
    blob_delete_retention_days        = optional(number, 30)
    container_delete_retention_days   = optional(number, 30)
    versioning_enabled                = optional(bool, true)
    change_feed_enabled               = optional(bool, true)
    storage_containers = optional(map(object({
      access_type = optional(string, "private")
    })), {})
    contributors                    = optional(set(string), [])
    allow_nested_items_to_be_public = optional(bool, false)
    cmk_key_vault_id                = optional(string, null)
    cmk_key_name                    = optional(string, null)
  })
  nullable = false
}