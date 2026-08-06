terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}

module "aws_byoc" {
  source      = "../..//modules/aws/byoc"
  external_id = "test-external-id"
}

output "role_arn" {
  value = module.aws_byoc.role_arn
}
