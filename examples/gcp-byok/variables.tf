variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "GCP region for the key (must match the data plane region)."
  default     = "us-central1"
}