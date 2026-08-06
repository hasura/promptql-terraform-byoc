# Example: GCP BYOK customer-managed key.
#   terraform init && terraform apply

module "gcp_byok" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/gcp/byok?ref=v0.1.0"

  project_id = var.project_id
  region     = var.region
}