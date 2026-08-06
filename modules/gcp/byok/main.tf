# GCP BYOK: customer-managed Cloud KMS key + key-scoped IAM for PromptQL.
# Equivalent of the "Create a key ring and KMS key" + "Grant PromptQL's
# provisioning service account access" steps in the Enterprise Deployment (GCP) guide.

resource "google_kms_key_ring" "this" {
  name     = var.keyring_name
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "this" {
  name     = var.key_name
  key_ring = google_kms_key_ring.this.id
  purpose  = var.purpose
  labels   = var.labels

  rotation_period = var.rotation_period
}

# Custom role: `hasuraDDNCMEKKeyAdmin` with exactly the three permissions
# PromptQL uses on the key. This is the GCP equivalent of the least-privilege
# key policy on AWS.
resource "google_project_iam_custom_role" "cmek_admin" {
  count       = var.create_custom_role ? 1 : 0
  project     = var.project_id
  role_id     = var.role_name
  title       = "PromptQL CMEK Key Admin"
  description = "Lets PromptQL automation read and bind IAM on a single KMS key, nothing else."
  permissions = [
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
  ]
  stage = "GA"
}

# Key-scoped IAM binding. Scoped to this key only, never project-wide.
resource "google_kms_crypto_key_iam_member" "cmek_binding" {
  crypto_key_id = google_kms_crypto_key.this.id
  role          = var.create_custom_role ? google_project_iam_custom_role.cmek_admin[0].id : var.predefined_role
  member        = "serviceAccount:${var.service_account}"
}