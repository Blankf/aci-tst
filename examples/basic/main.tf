terraform {
  required_version = ">= 0.13"
}

module "azure_devops_ccoe" {
  source = "../.."

  resource_group = {
    name     = "rg-ccoe-devops"
    location = "eastus"
  }

  network_security_group_rsg  = module.az_names["ntwk"].naming.management_governance.resource_groups
  network_security_group_name = "${module.az_names["ntwk"].naming.networking.virtual_network}-nsg"

  storage_account = {
    name                  = module.az_names["azdo"].naming.storage.storage_account
    cmk_key_vault_id      = module.ccoe_core.key_vault_id
    cmk_key_vault_keyname = module.ccoe_core.key_vault_cmkec_keyname
    ip_rules              = ["192.168.1.99"]

    contributors = [
      "00000000-0000-0000-0000-000000000000"
    ]
  }

  acr = {
    name = module.az_names["azdo"].naming.containers.container_registry
  }

  container_group = {
    name       = module.az_names["azdo"].naming.containers.container_instances
    subnet_ids = [module.ccoe_ntwk.subnet_list["DevopsSubnet"].id]
  }

  aci = {
    container1 = {
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
      cpu    = "1"
      memory = "1.5"
      ports = [
        {
          port     = "9997"
          protocol = "UDP"
        }
      ]
      environment_variables = {
        "ENVIRONMENT" = "dev"
      }
    }
  }

  tags = {
    environment = "dev"
  }
}

output "naming_convention" {
  value = module.azure_naming
}
