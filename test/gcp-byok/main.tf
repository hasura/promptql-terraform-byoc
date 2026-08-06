terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}

module "gcp_byok" {
  source     = "../..//modules/gcp/byok"
  project_id = "test-project"
  region     = "us-central1"
}

output "key_name" {
  value = module.gcp_byok.key_resource_name
}
