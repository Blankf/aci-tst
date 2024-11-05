terraform {
  required_version = ">= 0.13"
}

module "azure_devops_ccoe" {
  source = "../.."

  resource_group = {
    name     = "rg-ccoe-devops"
    location = "eastus"
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
