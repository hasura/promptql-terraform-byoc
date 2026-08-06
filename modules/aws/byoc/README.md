# AWS BYOC onboarding module

Provisions the IAM bootstrap role for a **PromptQL Enterprise BYOC** data plane in your AWS account.

This module is the Terraform equivalent of the CloudFormation template previously embedded in the [Enterprise Deployment (AWS) guide](https://promptql.io/en/docs/enterprise-deployment-aws). It creates:

- `HasuraCloudBYOC` IAM role with a trust relationship to PromptQL's automation role (`arn:aws:iam::760537944023:role/PulumiDDNCli`) constrained by an external ID.
- An inline `HasuraCloudBYOC` policy replicating the full least-privilege permission set from the CloudFormation template.

## Usage

```hcl
module "aws_byoc" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/aws/byoc?ref=v0.1.0"

  external_id = "<external-id-provided-by-promptql>"
}

output "role_arn" {
  value = module.aws_byoc.role_arn
}
```

1. `terraform init` and `terraform apply` in your AWS account.
2. Copy the **role ARN** and your **external ID** into the Create Data Plane form.

> [!IMPORTANT]
> `role_name`, `policy_name`, the trust ARN, and the `Created-By=HasuraCloud` tag scoping are operationally fixed identifiers for PromptQL automation. Do not change them unless instructed by PromptQL.
> The default `external_id` is `hasura-cloud` (the managed-flow default); use whatever value PromptQL provides for your data plane.

## Requirements

- AWS account dedicated to BYOC with administrative access for the initial bootstrap.
- `external_id` 2–1224 characters.
- VPC CIDR: reserve a non-overlapping /16–/20 CIDR (AWS exceptions: /21–/22 single-AZ, /23 with pod CIDR). See the [BYOC/BYOK CIDR policy](https://promptql.io/en/docs/enterprise-deployment).

## Adopting from the legacy CloudFormation bootstrap

If you previously deployed `cloudformation.yaml` from the docs:

- The module creates the same role name (`HasuraCloudBYOC`), trust, and inline policy.
- To avoid a conflict, either delete the old stack first, or import the existing role/policy into Terraform state:

```bash
terraform import 'module.aws_byoc.aws_iam_role.bootstrap_role' HasuraCloudBYOC
# the inline policy will show as an addition; delete it from the old stack after import
```

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| external_id | External ID for the trust relationship with PromptQL | string | `"hasura-cloud"` | no |
| gcp_project_name | GCP project ID used in the cross-cloud OIDC provider ARN | string | `"hasura-lux"` | no |
| role_name | Name of the bootstrap IAM role (fixed) | string | `"HasuraCloudBYOC"` | no |
| policy_name | Name of the inline policy (fixed) | string | `"HasuraCloudBYOC"` | no |
| tags | Optional tags on the role | map(string) | `{}` | no |

## Outputs

| Name | Description |
| --- | --- |
| role_arn | ARN of the BYOC IAM role |
| role_name | Name of the BYOC IAM role |
| external_id | External ID configured on the trust |
| trusted_automation_role_arn | PromptQL automation role ARN |