# GCP BYOK onboarding module

Provisions the **customer-managed Cloud KMS key** and key-scoped IAM for a **PromptQL Enterprise BYOK** data plane in your GCP project. PromptQL hosts the infrastructure on a dedicated data plane; your key encrypts all data at rest.

This module is the Terraform equivalent of the "Create a key ring and KMS key" + "Grant PromptQL's provisioning service account access" steps in the [Enterprise Deployment (GCP) guide](https://promptql.io/en/docs/enterprise-deployment-gcp). It creates:

- A key ring and symmetric encryption key in the data plane region.
- A custom `hasuraDDNCMEKKeyAdmin` role with exactly the three permissions PromptQL uses (`cloudkms.cryptoKeys.get`, `getIamPolicy`, `setIamPolicy`).
- A key-scoped IAM binding for `ddn-automation@hasura-ddn.iam.gserviceaccount.com`.

## Usage

```hcl
module "gcp_byok" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/gcp/byok?ref=v0.1.0"

  project_id = "your-project"
  region     = "us-central1"
}

output "key_resource_name" {
  value = module.gcp_byok.key_resource_name
}
```

1. Confirm the data plane region with PromptQL and run the module in a project in that region.
2. Paste `key_resource_name` into the **Customer-managed KMS Key Resource Name** field.

> [!IMPORTANT]
> The key must reside in the **same location** as the data plane.
> Revoking access to, disabling, or destroying a Cloud KMS key version that is in use **immediately impacts the data plane** and is a non-recoverable action — see the Enterprise guide's "Revoking access" section.

## Alternative: predefined role

Set `create_custom_role = false` to bind `predefined_role` (default `roles/cloudkms.admin`) at key scope instead of creating the custom role. Broader than necessary but still scoped to the single key.

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| project_id | GCP project ID | string | — | yes |
| region | GCP region for key ring/key | string | — | yes |
| keyring_name | Key ring name | string | `"hasura-ddn-cmek"` | no |
| key_name | Key name | string | `"hasura-ddn-cmek-key"` | no |
| service_account | PromptQL provisioning service account | string | `"ddn-automation@hasura-ddn.iam.gserviceaccount.com"` | no |
| role_name | Custom role short ID | string | `"hasuraDDNCMEKKeyAdmin"` | no |
| create_custom_role | Create the custom role (vs predefined) | bool | `true` | no |
| predefined_role | Predefined role when not creating custom | string | `"roles/cloudkms.admin"` | no |
| purpose | Key purpose | string | `"ENCRYPT_DECRYPT"` | no |
| rotation_period | Rotation period (e.g. `7776000s`), null disables | string | `null` | no |
| labels | Key labels | map(string) | `{}` | no |

## Outputs

| Name | Description |
| --- | --- |
| key_ring_id | Key ring ID |
| key_name | Crypto key ID |
| key_resource_name | Full Cloud KMS resource name |