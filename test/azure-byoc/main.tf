terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 5.0"
    }
  }
}

module "azure_byoc" {
  source = "../..//modules/azure/byoc"

  subscription_id      = "00000000-0000-0000-0000-000000000000"
  resource_group_names = ["rg-test"]
  principal_id         = "11111111-1111-1111-1111-111111111111"
}

output "custom_role_name" {
  value = module.azure_byoc.custom_role_name
}
