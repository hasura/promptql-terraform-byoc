# Example: GCP BYOC least-privilege IAM.
#   terraform init && terraform apply

module "gcp_byoc" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/gcp/byoc?ref=v0.1.0"

  project_id = var.project_id
}