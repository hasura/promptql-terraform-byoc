variable "subscription_id" {
  type        = string
  description = "Azure subscription ID where the BYOC data plane will be provisioned."
}

variable "resource_group_names" {
  type        = list(string)
  description = "Resource group names (existing or to-be-created) where role assignments are made."
}

variable "principal_id" {
  type        = string
  description = "Object ID of the principal (service principal / user / group) that PromptQL's automation uses."
}

variable "principal_type" {
  type        = string
  description = "Type of principal."
  default     = "ServicePrincipal"

  validation {
    condition     = contains(["User", "Group", "ServicePrincipal"], var.principal_type)
    error_message = "principal_type must be one of User, Group, ServicePrincipal."
  }
}

variable "custom_role_name" {
  type        = string
  description = "Name of the custom BYOC role. Operationally fixed; do not change."
  default     = "HasuraCloudBYOC"
}