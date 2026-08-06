# Example: Azure BYOC role assignments.
#   terraform init && terraform apply

module "azure_byoc" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/azure/byoc?ref=v0.1.0"

  subscription_id      = var.subscription_id
  resource_group_names = var.resource_group_names
  principal_id         = var.principal_id
}