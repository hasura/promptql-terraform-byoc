# GCP BYOC onboarding module

Provisions the least-privilege IAM setup for a **PromptQL Enterprise BYOC** data plane in your GCP project.

This module is the Terraform equivalent of the `main.tf` previously embedded in the [Enterprise Deployment (GCP) guide](https://promptql.io/en/docs/enterprise-deployment-gcp). It:

1. Enables the APIs PromptQL's provisioning automation needs.
2. Creates 12 custom least-privilege project roles (`promptqlDdn*`).
3. Binds them to PromptQL's `ddn-automation` service account.
4. Applies an IAM grant-restriction condition on the four roles that carry a `*.setIamPolicy` permission.

## Usage

```hcl
module "gcp_byoc" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/gcp/byoc?ref=v0.1.0"

  project_id = var.project_id
}
```

Apply as a project administrator in the dedicated GCP project.

> [!IMPORTANT]
> The role IDs, titles, descriptions, and the `ddn-automation@hasura-ddn.iam.gserviceaccount.com` principal are operationally fixed. Do not change them unless instructed by PromptQL.
> When PromptQL releases a newer version of this module, review the resulting `terraform plan` and apply it — this updates the custom roles and bindings with any new permissions the feature requires.

## Requirements

- Dedicated GCP project with billing enabled.
- Permission to create project-level custom roles and IAM bindings.
- VPC CIDR /16–/20. See the [BYOC/BYOK CIDR policy](https://promptql.io/en/docs/enterprise-deployment).

## Adopting from the legacy embedded `main.tf`

If you previously applied the embedded `main.tf` from the docs, replace it with this module and apply — Terraform will adopt the same roles and bindings (identifiers match exactly) instead of recreating them.

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| project_id | GCP project ID | string | — | yes |
| ddn_automation_service_account | PromptQL provisioning service account | string | `"ddn-automation@hasura-ddn.iam.gserviceaccount.com"` | no |

## Outputs

| Name | Description |
| --- | --- |
| project_id | GCP project ID |
| ddn_automation_service_account | Provisioning service account |
| custom_role_ids | Map of custom role IDs |
| enabled_apis | APIs enabled |