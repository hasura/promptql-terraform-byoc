variable "create_key" {
  type        = bool
  description = "Whether to create the customer-managed KMS key. Set to false and provide `existing_key_id` to use a key created outside this module."
  default     = true
}

variable "existing_key_id" {
  type        = string
  description = "ID (key ID or ARN) of an existing customer-managed KMS key to attach the policy to, when `create_key = false`."
  default     = null
}

variable "description" {
  type        = string
  description = "Description of the KMS key."
  default     = "PromptQL customer-managed encryption key"
}

variable "alias" {
  type        = string
  description = "Alias (without the `alias/` prefix) for the KMS key."
  default     = "hasura-ddn-cmek"
}

variable "deletion_window_in_days" {
  type        = number
  description = "KMS key deletion window in days."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Optional tags applied to the KMS key."
  default     = {}
}