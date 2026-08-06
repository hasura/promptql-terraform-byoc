# Example: AWS BYOK customer-managed key.
#   terraform init && terraform apply

module "aws_byok" {
  source = "github.com/hasura/promptql-terraform-byoc//modules/aws/byok?ref=v0.1.0"
}

output "key_arn" {
  value = module.aws_byok.key_arn
}