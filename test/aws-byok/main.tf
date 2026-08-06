terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}

module "aws_byok" {
  source = "../..//modules/aws/byok"
}

output "key_arn" {
  value = module.aws_byok.key_arn
}
