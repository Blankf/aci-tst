variable "container_group" {
  type = object({
    name                                = optional(string)
    location                            = optional(string)
    resource_group_name                 = optional(string)
    os_type                             = optional(string, "Linux")
    subnet_ids                          = optional(list(string))
    restart_policy                      = optional(string, "OnFailure")
    priority                            = optional(string, "Regular")
    key_vault_key_id                    = optional(string)
    key_vault_user_assigned_identity_id = optional(string)
    dns_name_label                      = optional(string)
    dns_name_label_reuse_policy         = optional(string)
    role_assignments    = optional(map(object({
      principal_id = string
      role         = string
    })))
    managed_identities = optional(object({
      system_assigned            = optional(bool, false)
      user_assigned_resource_ids = optional(set(string), [])
    }), {})
  })
  default = {}
  description = <<ACI_DETAILS
  This object describes the configuration for an Azure Container Instance.

  - `name`                            = (Required) - The name of the Container Group.
  - `location`                        = (Optional) - The location of the Container Group. Defaults to the location of the resource group.
  - `resource_group_name`             = (Optional) - The name of the resource group in which to create the Container Group. Defaults to the resource group of the parent module.
  - `os_type`                         = (Optional) - The OS type of the Container Group. Valid options are Linux and Windows. Defaults to Linux.
  - `subnet_ids`                      = (Required) - A list of subnet IDs to deploy the Container Group in.
  - `restart_policy`                  = (Optional) - The restart policy for the Container Group. Valid options are Always, OnFailure, and Never. Defaults to OnFailure.
  - `priority`                        = (Optional) - The priority of the Container Group. Valid options are Regular and Low. Defaults to Regular.
  - `key_vault_key_id`                = (Optional) - The Key Vault key ID for the Container Group.
  - `key_vault_user_assigned_identity_id` = (Optional) - The Key Vault user-assigned identity ID for the Container Group.

  Example Inputs:

  ```hcl
  module "aci" {
    name = "mycontainergroup"
    subnet_ids = [
      azurerm_subnet.this.id
    ]
  }
  ```
  ACI_DETAILS
  nullable    = false
}

variable "aci" {
  type = map(object({
    image  = string
    cpu    = optional(number, "1")
    memory = optional(number, "1")
    ports = list(object({
      port     = number
      protocol = string
    }))
    volumes = optional(map(object({
      mount_path           = string
      name                 = string
      read_only            = optional(bool, false)
      empty_dir            = optional(bool, false)
      secret               = optional(map(string), null)
      storage_account_name = optional(string, null)
      storage_account_key  = optional(string, null)
      share_name           = optional(string, null)
      git_repo = optional(object({
        url       = optional(string, null)
        directory = optional(string, null)
        revision  = optional(string, null)
      }))
    })), {})
    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {})
    commands                     = optional(list(string), null)
  }))
  default     = {}
  description = <<DESCRIPTION

- `image` = (Required) - The image to use for the container.
- `cpu` = (Optional) - The CPU to allocate to the container. Defaults to 1.
- `memory` = (Optional) - The memory to allocate to the container. Defaults to 1.
- `ports` = (Required) - A list of ports to expose on the container.
- `volumes` = (Optional) - A map of volumes to mount to the container.
- `environment_variables` = (Optional) - A map of environment variables to set in the container.
- `secure_environment_variables` = (Optional) - A map of secure environment variables to set in the container.
- `commands` = (Optional) - A list of commands to run in the container.

DESCRIPTION

}

variable "diagnostics_log_analytics" {
  type = object({
    workspace_id  = string
    workspace_key = string
  })
  default     = null
  description = "The Log Analytics workspace configuration for diagnostics."
}

variable "dns_name_label" {
  type        = string
  default     = null
  description = "The DNS name label for the container group."
}

variable "dns_name_servers" {
  type        = list(string)
  default     = []
  description = "A list of DNS name servers to use for the container group."
}

variable "exposed_ports" {
  type = list(object({
    port     = number
    protocol = string
  }))
  default     = []
  description = <<DESCRIPTION
A list of ports to expose on the container group.

- `port` = (Required) - The port to expose.
- `protocol` = (Required) - The protocol to use for the port. Valid options are TCP and UDP.
DESCRIPTION
}

variable "image_registry_credential" {
  type = map(object({
    user_assigned_identity_id = string
    server                    = string
    username                  = string
    password                  = string
  }))
  default     = {}
  description = "The credentials for the image registry."
}

variable "liveness_probe" {
  type = object({
    exec = object({
      command = list(string)
    })
    period_seconds        = number
    failure_threshold     = number
    success_threshold     = number
    timeout_seconds       = number
    initial_delay_seconds = number
    http_get = object({
      path         = string
      port         = number
      http_headers = map(string)
    })
    tcp_socket = object({
      port = number
    })
  })
  default     = null
  description = <<DESCRIPTION

- `exec` = (Optional) - The exec probe configuration.
- `period_seconds` = (Required) - The period in seconds between probe checks.
- `failure_threshold` = (Required) - The number of failures before the probe is considered failed.
- `success_threshold` = (Required) - The number of successes before the probe is considered successful.
- `timeout_seconds` = (Required) - The timeout in seconds for the probe.
- `initial_delay_seconds` = (Required) - The initial delay in seconds before the first probe check.
- `http_get` = (Optional) - The HTTP GET probe configuration.
- `tcp_socket` = (Optional) - The TCP socket probe configuration.

DESCRIPTION
}

variable "readiness_probe" {
  type = object({
    exec = object({
      command = list(string)
    })
    period_seconds        = number
    failure_threshold     = number
    success_threshold     = number
    timeout_seconds       = number
    initial_delay_seconds = number
    http_get = object({
      path         = string
      port         = number
      http_headers = map(string)
    })
    tcp_socket = object({
      port = number
    })
  })
  default     = null
  description = <<DESCRIPTION

- `exec` = (Optional) - The exec probe configuration.
- `period_seconds` = (Required) - The period in seconds between probe checks.
- `failure_threshold` = (Required) - The number of failures before the probe is considered failed.
- `success_threshold` = (Required) - The number of successes before the probe is considered successful.
- `timeout_seconds` = (Required) - The timeout in seconds for the probe.
- `initial_delay_seconds` = (Required) - The initial delay in seconds before the first probe check.
- `http_get` = (Optional) - The HTTP GET probe configuration.
- `tcp_socket` = (Optional) - The TCP socket probe configuration.

DESCRIPTION
}
