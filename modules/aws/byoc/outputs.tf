output "role_arn" {
  description = "ARN of the BYOC IAM role. Provide this to PromptQL in the Create Data Plane form."
  value       = aws_iam_role.bootstrap_role.arn
}

output "role_name" {
  description = "Name of the BYOC IAM role."
  value       = aws_iam_role.bootstrap_role.name
}

output "external_id" {
  description = "External ID configured on the trust relationship. Provide this to PromptQL."
  value       = var.external_id
}

output "trusted_automation_role_arn" {
  description = "PromptQL automation role ARN that will assume the bootstrap role."
  value       = "arn:aws:iam::760537944023:role/PulumiDDNCli"
}