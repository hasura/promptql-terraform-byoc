variable "project_id" {
  type        = string
  description = "The GCP project ID where the PromptQL data plane will be provisioned."
}

variable "ddn_automation_service_account" {
  type        = string
  description = "PromptQL's provisioning service account the custom roles are bound to."
  default     = "ddn-automation@hasura-ddn.iam.gserviceaccount.com"

  validation {
    condition     = can(regex("^[^@]+@[^.]+[.]iam[.]gserviceaccount[.]com$", var.ddn_automation_service_account))
    error_message = "ddn_automation_service_account must be a GCP service account email (name@project.iam.gserviceaccount.com)."
  }
}