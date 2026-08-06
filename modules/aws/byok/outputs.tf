output "key_id" {
  description = "ID of the customer-managed KMS key."
  value       = local.key_id
}

output "key_arn" {
  description = "ARN of the customer-managed KMS key. Paste into the Customer-managed KMS Key ARN field."
  value       = local.key_arn
}

output "key_alias" {
  description = "Alias ARN of the KMS key (when created by this module)."
  value       = var.create_key ? aws_kms_alias.this[0].arn : null
}

output "policy_json" {
  description = "The key policy JSON applied (or available to apply) to the key."
  value       = data.aws_iam_policy_document.key_policy.json
}