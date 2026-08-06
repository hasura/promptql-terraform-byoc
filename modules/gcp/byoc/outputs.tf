output "project_id" {
  description = "The GCP project ID."
  value       = var.project_id
}

output "ddn_automation_service_account" {
  description = "PromptQL provisioning service account the roles are bound to."
  value       = var.ddn_automation_service_account
}

output "custom_role_ids" {
  description = "Map of custom role short IDs created by the module."
  value       = { for k, v in local.custom_roles : k => google_project_iam_custom_role.roles[k].role_id }
}

output "enabled_apis" {
  description = "APIs enabled by the module."
  value       = local.required_apis
}