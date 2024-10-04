variable "acr" {
  type = object({
    name                          = optional(string)
    resource_group_name           = optional(string)
    location                      = optional(string)
    sku                           = optional(string, "Premium")
    anonymous_pull_enabled        = optional(bool, false)
    quarantine_policy_enabled     = optional(bool, false)
    admin_enabled                 = optional(bool, false)
    public_network_access_enabled = optional(bool, false)
    export_policy_enabled         = optional(bool, false)
    retention_policy_in_days      = optional(number, 7)
    network_bypass                = optional(string, "None")
    customer_managed_key = optional(object({
      key_vault_resource_id = string
      key_name              = string
      key_version           = optional(string, null)
      user_assigned_identity = optional(object({
        resource_id = string
      }), null)
    }))
    managed_identities = optional(object({
      system_assigned            = optional(bool, false)
      user_assigned_resource_ids = optional(set(string), [])
    }), {})
    network_rule_set  = optional(object({
      default_action    = optional(string, "Deny")
      ip_rule   = optional(list(object({
      # since the `action` property only permits `Allow`, this is hard-coded.
      action   = optional(string, "Allow")
      ip_range = string
    })), [])
    }), null)
    tags                    = optional(map(string))
    zone_redundancy_enabled = optional(bool, false)
  })
  default     = {}
  nullable    = false
  description = <<ACR_DETAILS
This object describes the configuration for an Azure Container Registry.

- `name`                            = (Optional) - The name of the Container Registry.
- `identity`                        = (Optional) - Enable or disable the Managed Identity for the Container Registry. Defaults to true.
- `resource_group_name`             = (Optional) - The name of the resource group in which to create the Container Registry. Defaults to the resource group of the parent module.
- `location`                        = (Optional) - The location of the Container Registry. Defaults to the location of the resource group.
- `sku`                             = (Optional) - The SKU of the Container Registry. Valid options are Basic, Standard, and Premium. Defaults to Premium.
- `admin_enabled`                   = (Optional) - Enable or disable the Admin user for the Container Registry. Defaults to false.
- `public_network_access_enabled`   = (Optional) - Enable or disable public network access for the Container Registry. Defaults to false.
- `retention_policy_in_days`        = (Optional) - The number of days to retain untagged manifests. Defaults to 7.
- `network_bypass`                  = (Optional) - A string of services that are allowed to bypass the network rules. Defaults to "None" but could be any of "AzureServices" or "None".
- `customer_managed_key`            = (Optional) - A map of the Customer Managed Key configuration for the Container Registry.
  - `key_vault_resource_id`         = (Required) - The Resource ID of the Key Vault that the Customer Managed Key belongs to.
  - `key_name`                      = (Required) - The name of the Customer Managed Key.
  - `key_version`                   = (Optional) - The version of the Customer Managed Key.
  - `user_assigned_identity`        = (Optional) - The User Assigned Identity that has access to the key.
    - `resource_id`                 = (Required) - The Resource ID of the User Assigned Identity that has access to the key.
- `network_rule`                    = (Optional) - A map of network rules to apply to the Container Registry.
  - `default_action`                = (Required) - The default action for the network rules. Valid options are Allow and Deny.
  - `ip_rules`                      = (Required) - A list of IP addresses that are allowed to access the Container Registry.
- `tags`                            = (Optional) - A mapping of tags to assign to the Container Registry.
- `zone_redundancy_enabled`         = (Optional) - Enable or disable zone redundancy for the Container Registry. Defaults to false.

Example Inputs:

```hcl
module "acr" "this" {
  name              = "acrname"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rgname"
  location          = "eastus"
  sku               = "Basic"
  admin_enabled     = false
  network_rule      = {
    default_action = "Deny"
    ip_rules       = [ "
```
}
ACR_DETAILS

  validation {
    condition     = can(regex("^[[:alnum:]]{5,50}$", var.acr.name))
    error_message = "The name must be between 5 and 50 characters long and can only contain letters and numbers."
  }
}

# variable "customer_managed_key" {
#   type = object({
#     key_vault_resource_id = string
#     key_name              = string
#     key_version           = optional(string, null)
#     user_assigned_identity = optional(object({
#       resource_id = string
#     }), null)
#   })
#   default     = null
#   description = <<DESCRIPTION
# A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
# Controls the Customer managed key configuration on this resource. The following properties can be specified:
# - `key_vault_resource_id` - (Required) Resource ID of the Key Vault that the customer managed key belongs to.
# - `key_name` - (Required) Specifies the name of the Customer Managed Key Vault Key.
# - `key_version` - (Optional) The version of the Customer Managed Key Vault Key.
# - `user_assigned_identity` - (Optional) The User Assigned Identity that has access to the key.
#   - `resource_id` - (Required) The resource ID of the User Assigned Identity that has access to the key.
# DESCRIPTION
# }


# variable "managed_identities" {
#   type = object({
#     system_assigned            = optional(bool, false)
#     user_assigned_resource_ids = optional(set(string), [])
#   })
#   default     = {}
#   description = <<DESCRIPTION
# Controls the Managed Identity configuration on this resource. The following properties can be specified:

# - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
# - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
# DESCRIPTION
#   nullable    = false
# }