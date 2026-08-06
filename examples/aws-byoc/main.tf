# Example: AWS BYOC bootstrap.
#   terraform init && terraform apply

module "aws_byoc" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/aws/byoc?ref=v0.1.0"

  external_id = var.external_id
}

output "role_arn" {
  value = module.aws_byoc.role_arn
}