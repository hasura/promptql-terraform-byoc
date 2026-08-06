variable "project_id" {
  type        = string
  description = "The GCP project ID where the KMS key will be created."
}

variable "region" {
  type        = string
  description = "The GCP region for the key ring and key (must match the data plane region)."
}

variable "keyring_name" {
  type        = string
  description = "Name of the key ring."
  default     = "hasura-ddn-cmek"
}

variable "key_name" {
  type        = string
  description = "Name of the KMS key."
  default     = "hasura-ddn-cmek-key"
}

variable "service_account" {
  type        = string
  description = "PromptQL provisioning service account granted the key-scoped admin role."
  default     = "ddn-automation@hasura-ddn.iam.gserviceaccount.com"
}

variable "role_name" {
  type        = string
  description = "Short ID of the custom role created at project level."
  default     = "hasuraDDNCMEKKeyAdmin"
}

variable "create_custom_role" {
  type        = bool
  description = "Whether to create the custom CMEK key-admin role. Set false to use a predefined role instead (e.g. roles/cloudkms.admin)."
  default     = true
}

variable "predefined_role" {
  type        = string
  description = "Predefined role to bind at key scope when create_custom_role = false."
  default     = "roles/cloudkms.admin"
}

variable "purpose" {
  type        = string
  description = "Purpose of the KMS key."
  default     = "ENCRYPT_DECRYPT"
}

variable "rotation_period" {
  type        = string
  description = "Rotation period for the key (e.g. 7776000s). Null disables automatic rotation."
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "Optional labels for the key."
  default     = {}
}