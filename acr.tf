resource "azurerm_container_registry" "this" {
  name                     = var.acr.name
  location                 = var.acr.location == null ? var.resource_group.location : var.acr.location
  resource_group_name      = var.acr.resource_group_name == null ? var.resource_group.name : var.acr.resource_group_name
  sku                      = var.acr.sku
  admin_enabled            = var.acr.admin_enabled
  anonymous_pull_enabled   = var.acr.anonymous_pull_enabled
  retention_policy_in_days = var.acr.retention_policy_in_days
  #data_endpoint_enabled         = var.acr.data_endpoint_enabled
  export_policy_enabled         = var.acr.export_policy_enabled
  network_rule_bypass_option    = var.acr.network_bypass
  public_network_access_enabled = var.acr.public_network_access_enabled
  quarantine_policy_enabled     = var.acr.quarantine_policy_enabled
  zone_redundancy_enabled       = var.acr.zone_redundancy_enabled

  # dynamic "encryption" {
  #   for_each = var.customer_managed_key != null ? { this = var.customer_managed_key } : {}

  #   content {
  #     enabled            = true # deprecated property. Still required to enable encryption
  #     identity_client_id = var.acr.customer_managed_key.identity_client_id
  #     key_vault_key_id   = var.acr.customer_managed_key.key_vault_key_id
  #   }
  # }

  # dynamic "georeplications" {
  #   for_each = local.ordered_geo_replications

  #   content {
  #     location                  = georeplications.value.location
  #     regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
  #     tags                      = georeplications.value.tags
  #     zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
  #   }
  # }

  dynamic "identity" {
    for_each = local.acr_managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  # Only one network_rule_set block is allowed.
  # Create it if the variable is not null.
  dynamic "network_rule_set" {
    for_each = var.acr.network_rule_set != null ? { this = var.acr.network_rule_set } : {}

    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule

        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  tags = merge(
    var.tags,
    tomap({
      "ResourceType" = "Container Registry"
    })
  )


  # this is to make sure that when you have standard, but selected premium features, it will tell you that you have to use premium sku or nullify the premium features

  lifecycle {
    precondition {
      condition     = var.acr.zone_redundancy_enabled != null && var.acr.sku == "Premium" || var.acr.network_rule_set == null
      error_message = "The Premium SKU is required if zone redundancy is enabled."
    }
    precondition {
      condition     = var.acr.network_rule_set != null && var.acr.sku == "Premium" || var.acr.network_rule_set == null
      error_message = "The Premium SKU is required if a network rule set is defined."
    }
    precondition {
      condition     = var.acr.customer_managed_key != null && var.acr.sku == "Premium" || var.acr.customer_managed_key == null
      error_message = "The Premium SKU is required if a customer managed key is defined."
    }
    precondition {
      condition     = var.acr.quarantine_policy_enabled != null && var.acr.sku == "Premium" || var.acr.quarantine_policy_enabled == null
      error_message = "The Premium SKU is required if quarantine policy is enabled."
    }
    precondition {
      condition     = var.acr.retention_policy_in_days != null && var.acr.sku == "Premium" || var.acr.retention_policy_in_days == null
      error_message = "The Premium SKU is required if retention policy is defined."
    }
    precondition {
      condition     = var.acr.export_policy_enabled != null && var.acr.sku == "Premium" || var.acr.export_policy_enabled == null
      error_message = "The Premium SKU is required if export policy is enabled."
    }
    precondition {
      condition     = var.acr.zone_redundancy_enabled != null && var.acr.sku == "Premium" || var.acr.zone_redundancy_enabled == null
      error_message = "The Premium SKU is required if zone redundancy is enabled."
    }
  }
}

