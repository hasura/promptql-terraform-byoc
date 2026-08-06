# Azure BYOC onboarding module

Provisions the custom role and resource-group role assignments for a **PromptQL Enterprise BYOC** data plane in your Azure subscription.

This module is the Terraform equivalent of the ARM template previously embedded in the [Enterprise Deployment (Azure) guide](https://promptql.io/en/docs/enterprise-deployment-azure). It:

- Creates the `HasuraCloudBYOC` custom role (PostgreSQL flexible server management).
- Assigns the custom role plus Network Contributor, Managed Identity Contributor, Managed Identity Operator, AKS Contributor, Storage Account Contributor, and RBAC Administrator (with a scoping condition) in each resource group.

## Usage

```hcl
module "azure_byoc" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/azure/byoc?ref=v0.1.0"

  subscription_id      = "<subscription-id>"
  resource_group_names = ["rg-hasura-data-plane"]
  principal_id         = "<service-principal-or-msi-object-id>"
}
```

1. Create the service principal for "Hasura Cloud Infrastructure Manager" (App ID `4f7f1f59-f0b0-4adb-8603-2afacc50552b`) in your tenant if you haven't already.
2. Run the module at subscription scope with the approved resource groups.
3. Provide the subscription ID, principal object ID, and resource group names to PromptQL.

> [!IMPORTANT]
> The custom role name (`HasuraCloudBYOC`), the built-in role definition IDs, and the RBAC administrator condition are operationally fixed. Do not change them.

## Requirements

- Dedicated Azure subscription or approved resource groups.
- Permission to register Enterprise applications and assign roles.

## Adopting from the legacy ARM template

If you previously deployed `role.json` from the docs, replace it with this module. The custom role name and role-assignment GUIDs are derived identically; Terraform will adopt the same role and assignments rather than recreating them.

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| subscription_id | Azure subscription ID | string | — | yes |
| resource_group_names | Resource groups for assignments | list(string) | — | yes |
| principal_id | Principal object ID | string | — | yes |
| principal_type | Principal type | string | `"ServicePrincipal"` | no |
| custom_role_name | Custom role name (fixed) | string | `"HasuraCloudBYOC"` | no |

## Outputs

| Name | Description |
| --- | --- |
| custom_role_name | Custom role name |
| custom_role_definition_id | Custom role definition resource ID |
| assigned_resource_groups | Assigned resource groups |