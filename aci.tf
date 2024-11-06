resource "azurerm_user_assigned_identity" "this" {
  count               = var.container_group != null ? 1 : 0
  name                = "${var.container_group.name}-mid"
  location            = var.container_group.location == null ? azurerm_resource_group.this.location : var.container_group.location
  resource_group_name = var.container_group.resource_group_name == null ? azurerm_resource_group.this.name : var.container_group.resource_group_name
}

resource "azurerm_role_assignment" "this" {
  for_each = var.container_group.role_assignments != null ? var.container_group.role_assignments : {}

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.id

  lifecycle {
    precondition {
      condition     = provider::azurerm::parse_resource_id(each.value.scope)["resource_provider"] == "Microsoft.ContainerRegistry"
      error_message = "The scope must be an Azure Container Registry."
    }
    precondition {
      condition     = each.value.role_definition_name == "acrpull" || each.value.role_definition_name == "acrpush"
      error_message = "The role definition must be either 'acrpull' or 'acrpush'."
    }
    precondition {
      condition     = can(regex("^([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$", each.value.id))
      error_message = "The principal ID must be a valid object ID or principal ID."
    }
  }
}

resource "azurerm_container_group" "this" {
  count                              = var.container_group != null ? 1 : 0

  name                               = var.container_group.name
  location                           = var.container_group.location == null ? azurerm_resource_group.this.location : var.container_group.location
  resource_group_name                = var.container_group.resource_group_name == null ? azurerm_resource_group.this.name : var.container_group.resource_group_name
  os_type                            = var.container_group.os_type
  dns_name_label                     = length(var.container_group.subnet_ids) == 0 ? var.dns_name_label : null
  dns_name_label_reuse_policy        = var.container_group.dns_name_label_reuse_policy
  ip_address_type                    = length(var.container_group.subnet_ids) == 0 ? "Public" : "Private"
  key_vault_key_id                   = var.container_group.key_vault_key_id
  key_vault_user_assigned_identity_id = var.container_group.key_vault_user_assigned_identity_id
  priority                           = var.container_group.priority
  restart_policy                     = var.container_group.restart_policy
  subnet_ids                         = length(var.container_group.subnet_ids) == 0 ? null : var.container_group.subnet_ids
  zones                              = var.zones

  dynamic "container" {
    for_each = var.aci
    content {
      cpu                          = container.value.cpu
      image                        = container.value.image
      memory                       = container.value.memory
      name                         = container.key
      commands                     = try(container.value.commands, null)
      environment_variables        = try(container.value.environment_variables, null)
      secure_environment_variables = try(container.value.secure_environment_variables, null)

      dynamic "liveness_probe" {
        for_each = try(var.liveness_probe, null) == null ? [] : [1]

        content {
          exec                  = try(liveness_probe.value.exec, null)
          failure_threshold     = try(liveness_probe.value.failure_threshold, 3)
          initial_delay_seconds = try(liveness_probe.value.initial_delay_seconds, null)
          period_seconds        = try(liveness_probe.value.period_seconds, 10)
          success_threshold     = try(liveness_probe.value.success_threshold, 1)
          timeout_seconds       = try(liveness_probe.value.timeout_seconds, 1)

          dynamic "http_get" {
            for_each = try(liveness_probe.value.http_get, {}) == {} ? [] : [1]

            content {
              path   = try(http_get.value.path, null)
              port   = try(http_get.value.port, null)
              scheme = try(http_get.value.scheme, null)
            }
          }
        }
      }
      dynamic "ports" {
        for_each = container.value.ports
        content {
          port     = ports.value.port
          protocol = try(upper(ports.value.protocol), "TCP")
        }
      }
      dynamic "readiness_probe" {
        for_each = try(var.readiness_probe, null) == null ? [] : [1]

        content {
          exec                  = try(readiness_probe.value.exec, null)
          failure_threshold     = try(readiness_probe.value.failure_threshold, 3)
          initial_delay_seconds = try(readiness_probe.value.initial_delay_seconds, null)
          period_seconds        = try(readiness_probe.value.period_seconds, 10)
          success_threshold     = try(readiness_probe.value.success_threshold, 1)
          timeout_seconds       = try(readiness_probe.value.timeout_seconds, 1)

          dynamic "http_get" {
            for_each = try(readiness_probe.value.http_get, {}) == {} ? [] : [1]

            content {
              path   = try(http_get.value.path, null)
              port   = try(http_get.value.port, null)
              scheme = try(http_get.value.scheme, null)
            }
          }
        }
      }
      dynamic "volume" {
        for_each = container.value.volumes
        content {
          mount_path = volume.value.mount_path
          name       = volume.key
          empty_dir  = try(volume.value.empty_dir, false)
          read_only  = try(volume.value.read_only, false)
          secret               = try(volume.value.secret, null)
          share_name           = try(volume.value.share_name, null)
          storage_account_key  = try(volume.value.storage_account_key, null)
          storage_account_name = try(volume.value.storage_account_name, null)

          dynamic "git_repo" {
            for_each = volume.value.git_repo != null ? [volume.value.git_repo] : []
            content {
              url       = git_repo.value.url
              directory = git_repo.value.directory
              revision  = git_repo.value.revision
            }
          }
        }
      }
    }
  }

  dynamic "diagnostics" {
    for_each = var.diagnostics_log_analytics != null ? [var.diagnostics_log_analytics] : []
    content {
      log_analytics {
        workspace_id  = diagnostics.value.workspace_id
        workspace_key = diagnostics.value.workspace_key
      }
    }
  }

  dynamic "dns_config" {
    for_each = toset(length(var.dns_name_servers) > 0 ? [var.dns_name_servers] : [])
    content {
      nameservers    = dns_config.value
      options        = try(dns_config.options, null)
      search_domains = try(dns_config.search_domains, null)
    }
  }

  dynamic "exposed_port" {
    for_each = var.exposed_ports
    content {
      port     = exposed_port.value.port
      protocol = upper(exposed_port.value.protocol)
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this[0].id
    ]
  }

  dynamic "image_registry_credential" {
    for_each = var.image_registry_credential
    content {
      server                    = azurerm_container_registry.this.login_server
      user_assigned_identity_id = azurerm_user_assigned_identity.this[0].id
    }
  }

  tags = merge(
    var.tags,
    tomap({
      "ResourceType" = "ContainerGroup"
    })
  )

  timeouts {
    create = "2h"
    update = "2h"
  }
}
