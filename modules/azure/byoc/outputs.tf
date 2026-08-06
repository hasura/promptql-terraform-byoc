output "custom_role_name" {
  description = "Name of the custom BYOC role."
  value       = azurerm_role_definition.byoc_custom.name
}

output "custom_role_definition_id" {
  description = "Resource ID of the custom BYOC role definition."
  value       = azurerm_role_definition.byoc_custom.role_definition_resource_id
}

output "assigned_resource_groups" {
  description = "Resource groups the role assignments were made in."
  value       = var.resource_group_names
}