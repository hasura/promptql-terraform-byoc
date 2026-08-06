# AWS BYOK onboarding module

Provisions the **customer-managed KMS key** and key policy for a **PromptQL Enterprise BYOK** data plane. PromptQL hosts the infrastructure on a dedicated data plane; your key encrypts all data at rest.

This module is the Terraform equivalent of the "Create a KMS key" + "Configure key policy" steps in the [Enterprise Deployment (AWS) guide](https://promptql.io/en/docs/enterprise-deployment-aws). It creates:

- A symmetric customer-managed KMS key (same region as the data plane).
- An optional alias (`alias/hasura-ddn-cmek` by default).
- The three-statement key policy granting:
  - account-root administration (`EnableIAMUserPermissions`),
  - PromptQL's automation role (`arn:aws:iam::824267124885:role/HasuraDataPlaneAutomation`) `kms:CreateGrant` limited to data-at-rest grant operations (`AllowHasuraDDNCreateGrant`),
  - `kms:DescribeKey` / `kms:ListGrants` for visibility (`AllowHasuraDDNDescribeKey`).

## Usage

```hcl
module "aws_byok" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/aws/byok?ref=v0.1.0"
}

output "key_arn" {
  value = module.aws_byok.key_arn
}
```

1. Confirm the data plane region with PromptQL and run the module **in that region**.
2. Paste the `key_arn` into the **Customer-managed KMS Key ARN** field.

> [!IMPORTANT]
> The key must reside in the **same region** as the data plane.
> Revoking, disabling, or deleting a customer-managed KMS key in use **immediately impacts the data plane** and is a non-recoverable action — see the Enterprise guide's "Revoking access" section.

## Using an existing key

Set `create_key = false` and pass `existing_key_id` (key ID or ARN). The module will not create a key; it will still emit the policy JSON (via `policy_json`) that must be applied to the existing key. Applying a key policy to an externally-managed key is outside Terraform's control — apply `policy_json` with `aws kms put-key-policy` or your existing key-management process.

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| create_key | Whether to create the KMS key | bool | `true` | no |
| existing_key_id | Existing key ID/ARN when `create_key = false` | string | `null` | no |
| description | Key description | string | `"PromptQL customer-managed encryption key"` | no |
| alias | Key alias (no `alias/` prefix) | string | `"hasura-ddn-cmek"` | no |
| deletion_window_in_days | Deletion window | number | `30` | no |
| tags | Optional tags on the key | map(string) | `{}` | no |

## Outputs

| Name | Description |
| --- | --- |
| key_id | KMS key ID |
| key_arn | KMS key ARN |
| key_alias | Alias ARN (when key created) |
| policy_json | Key policy JSON |