terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}

module "gcp_byoc" {
  source     = "../..//modules/gcp/byoc"
  project_id = "test-project"
}

output "role_ids" {
  value = module.gcp_byoc.custom_role_ids
}
