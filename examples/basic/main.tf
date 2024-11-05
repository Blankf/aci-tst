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
    name = "test-acr"
  }

  container_group = {
    name       = "test-containergroup"
    subnet_ids = "DevopsSubnet"
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
