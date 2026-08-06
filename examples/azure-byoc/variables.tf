variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "resource_group_names" {
  type        = list(string)
  description = "Approved resource group names."
}

variable "principal_id" {
  type        = string
  description = "Object ID of the service principal used by PromptQL."
}