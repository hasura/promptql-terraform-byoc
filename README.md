# PromptQL BYOC / BYOK Onboarding Terraform Modules

Customer-side bootstrap Terraform modules for **PromptQL Enterprise** data planes. Run these in your own cloud account (AWS, GCP, or Azure) to grant PromptQL's provisioning automation the least-privilege access it needs to deploy and operate a data plane.

This repository replaces the manual CloudFormation / gcloud / ARM bootstrap configs previously embedded in the PromptQL Enterprise Deployment guides. The modules preserve the operationally fixed identifiers and trust relationships used by PromptQL automation — do not change them.

## Deployment models

- **BYOC (Bring Your Own Cloud)** — you provide the cloud account and IAM trust relationship; PromptQL's automation (Pulumi) provisions and operates all data plane infrastructure inside your account.
- **BYOK (Bring Your Own Key)** — PromptQL hosts the infrastructure on a dedicated data plane, but all data at rest is encrypted with a customer-managed KMS key. Supported on AWS and GCP; not currently supported on Azure.

## Modules

| Cloud | Module | Model | What it creates |
| --- | --- | --- | --- |
| AWS | [`modules/aws/byoc`](./modules/aws/byoc) | BYOC | `HasuraCloudBYOC` IAM role and policy, with trust to `arn:aws:iam::760537944023:role/PulumiDDNCli` + external ID |
| AWS | [`modules/aws/byok`](./modules/aws/byok) | BYOK | Customer-managed KMS key + alias and the three-statement key policy for the Hasura data-plane automation role |
| GCP | [`modules/gcp/byoc`](./modules/gcp/byoc) | BYOC | Required APIs, 12 custom least-privilege `promptqlDdn*` roles, and IAM bindings (with grant-restriction conditions) for `ddn-automation@hasura-ddn.iam.gserviceaccount.com` |
| GCP | [`modules/gcp/byok`](./modules/gcp/byok) | BYOK | Cloud KMS key ring + key, custom `hasuraDDNCMEKKeyAdmin` role, and key-scoped IAM binding |
| Azure | [`modules/azure/byoc`](./modules/azure/byoc) | BYOC | `HasuraCloudBYOC` custom role and resource-group role assignments, including the conditioned RBAC administrator assignment |

Azure Dedicated/BYOK is not supported — no `azure/byok` module is provided.

## Quick start

Pick the module for your cloud and deployment model and follow its README. For example, AWS BYOC:

```hcl
module "aws_byoc" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/aws/byoc?ref=v0.1.0"

  external_id = "<external-id-you-provide-to-promptql>"
}

output "role_arn" {
  value = module.aws_byoc.role_arn
}
```

```bash
terraform init
terraform plan
terraform apply
```

Then provide the module outputs (role ARN, project ID, subscription/principal IDs, etc.) to PromptQL in the Create Data Plane form.

## Requirements

- Terraform >= 1.3
- Provider credentials for the target cloud (see each module README)
- Follow the [BYOC/BYOK CIDR policy](https://promptql.io/en/docs/enterprise-deployment): reserve a /16–/20 VPC CIDR (/21–/23 on AWS only with the documented exceptions)

## Releases & versioning

Every push to `main` that changes `modules/**` is released automatically as a single repository-wide `vMAJOR.MINOR.PATCH` tag covering all modules. Bump is derived from conventional-commit subjects merged since the last release (`feat!`/`BREAKING CHANGE` = major, `feat` = minor, else patch). Changes limited to module `README.md` files do not trigger a release. Label a PR `release:major` / `release:minor` / `release:patch` to override, or `release:skip` to hold.

Pin module sources to a release tag (e.g. `?ref=v0.1.0`) — never pin to `main`.

## Upgrade / adoption notes

- If you previously deployed the CloudFormation / gcloud / ARM bootstrap configs from the Enterprise Deployment guides, see the "Adopting from the legacy bootstrap" section in the relevant module README before reapplying.

## CI

- `lint.yaml` — runs `terraform fmt -check` and `terraform validate` on every PR.
- `auto-release.yaml` — validates and tags a release when module files change on `main`.

## License

Apache-2.0 — see [LICENSE](./LICENSE).