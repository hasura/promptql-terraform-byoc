variable "external_id" {
  type        = string
  description = "External ID for the trust relationship with PromptQL. PromptQL provides this value during onboarding; the documented default for the managed flow is `hasura-cloud`."
  default     = "hasura-cloud"

  validation {
    # Note: {2,1224} cannot be used in a single regex because Terraform's RE2
    # engine caps repeat counts at 1000; check bounds + charset separately.
    condition     = length(var.external_id) >= 2 && length(var.external_id) <= 1224 && can(regex("^[A-Za-z0-9+=,.@:/-]+$", var.external_id))
    error_message = "external_id must be 2-1224 characters and match the AWS ExternalId pattern."
  }
}

variable "gcp_project_name" {
  type        = string
  description = "GCP project ID referenced by the OIDC provider ARN for cross-cloud BYOC (used by PromptQL automation; keep the documented default unless instructed otherwise)."
  default     = "hasura-lux"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,255}$", var.gcp_project_name))
    error_message = "gcp_project_name must be a lowercase GCP project ID pattern."
  }
}

variable "role_name" {
  type        = string
  description = "Name of the BYOC bootstrap IAM role. This is an operationally fixed identifier for PromptQL automation; do not change it."
  default     = "HasuraCloudBYOC"
}

variable "policy_name" {
  type        = string
  description = "Name of the inline policy attached to the bootstrap role. Operationallly fixed; do not change it."
  default     = "HasuraCloudBYOC"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags applied to the bootstrap role."
  default     = {}
}