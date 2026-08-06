output "key_ring_id" {
  description = "ID of the key ring."
  value       = google_kms_key_ring.this.id
}

output "key_name" {
  description = "ID of the KMS crypto key."
  value       = google_kms_crypto_key.this.id
}

output "key_resource_name" {
  description = "Full Cloud KMS resource name. Paste into the Customer-managed KMS Key Resource Name field."
  value       = google_kms_crypto_key.this.id
}