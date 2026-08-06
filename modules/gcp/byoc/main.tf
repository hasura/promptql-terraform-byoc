locals {
  member = "serviceAccount:${var.ddn_automation_service_account}"

  # APIs the data-plane project must have enabled for provisioning to run.
  required_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudkms.googleapis.com",
    "certificatemanager.googleapis.com",
    "gkehub.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "multiclusteringress.googleapis.com",
    "trafficdirector.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com", # google_project_iam_member goes through Resource Manager
  ]

  # Each setIamPolicy-bearing role below carries its OWN `grantable_roles` allowlist, scoped to
  # exactly the roles ddn-automation grants at that resource level (project / SA / bucket / key).
  # The grant-restriction condition on each binding is built from that per-role list.
  custom_roles = {
    compute_network_admin = {
      role_id     = "promptqlDdnComputeNetworkAdmin"
      title       = "PromptQL DDN - Compute Network Admin"
      description = "Least-privilege replacement for roles/compute.networkAdmin, scoped to PromptQL provisioning"
      permissions = [
        "compute.networks.create",
        "compute.networks.get",
        "compute.networks.list",
        "compute.networks.update",
        "compute.networks.delete",
        "compute.networks.use",
        "compute.networks.updatePolicy",
        "compute.subnetworks.create",
        "compute.subnetworks.get",
        "compute.subnetworks.list",
        "compute.subnetworks.update",
        "compute.subnetworks.delete",
        "compute.subnetworks.use",
        "compute.subnetworks.setPrivateIpGoogleAccess",
        "compute.routers.create",
        "compute.routers.get",
        "compute.routers.list",
        "compute.routers.update",
        "compute.routers.delete",
        "compute.routers.use",
        "compute.addresses.create",
        "compute.addresses.get",
        "compute.addresses.list",
        "compute.addresses.delete",
        "compute.addresses.use",
        "compute.globalAddresses.create",
        "compute.globalAddresses.get",
        "compute.globalAddresses.list",
        "compute.globalAddresses.delete",
        "compute.globalAddresses.use",
        "compute.globalAddresses.createInternal",
        "compute.globalAddresses.deleteInternal",
        "compute.globalOperations.get",
        "compute.globalOperations.list",
        "compute.regionOperations.get",
        "compute.regionOperations.list",
        "compute.projects.get",
        "servicenetworking.services.addPeering",
        "servicenetworking.services.get",
        "servicenetworking.services.deleteConnection",
        "servicenetworking.operations.get",
      ]
    }

    dns_admin = {
      role_id     = "promptqlDdnDnsAdmin"
      title       = "PromptQL DDN - DNS Admin"
      description = "Least-privilege replacement for roles/dns.admin, scoped to PromptQL provisioning"
      permissions = [
        "dns.managedZones.create",
        "dns.managedZones.get",
        "dns.managedZones.list",
        "dns.managedZones.update",
        "dns.managedZones.delete",
        "dns.resourceRecordSets.create",
        "dns.resourceRecordSets.get",
        "dns.resourceRecordSets.list",
        "dns.resourceRecordSets.update",
        "dns.resourceRecordSets.delete",
        "dns.changes.create",
        "dns.changes.get",
        "dns.changes.list",
        "dns.managedZoneOperations.get",
        "dns.managedZoneOperations.list",
        "dns.projects.get",
        "dns.networks.bindPrivateDNSZone",
      ]
    }

    gkehub_editor = {
      role_id     = "promptqlDdnGkeHubEditor"
      title       = "PromptQL DDN - GKE Hub Editor"
      description = "Least-privilege replacement for roles/gkehub.editor, scoped to PromptQL provisioning"
      permissions = [
        "gkehub.features.create",
        "gkehub.features.get",
        "gkehub.features.list",
        "gkehub.features.update",
        "gkehub.features.delete",
        "gkehub.memberships.create",
        "gkehub.memberships.get",
        "gkehub.memberships.list",
        "gkehub.memberships.update",
        "gkehub.memberships.delete",
        "gkehub.operations.get",
        "gkehub.operations.list",
        "gkehub.locations.get",
        "gkehub.locations.list",
      ]
    }

    container_cluster_admin = {
      role_id     = "promptqlDdnContainerClusterAdmin"
      title       = "PromptQL DDN - Container Cluster Admin"
      description = "Least-privilege replacement for roles/container.clusterAdmin, scoped to PromptQL provisioning"
      permissions = [
        "container.clusters.create",
        "container.clusters.get",
        "container.clusters.list",
        "container.clusters.update",
        "container.clusters.delete",
        "container.operations.get",
        "container.operations.list",
        "resourcemanager.projects.get",
        "compute.instanceGroupManagers.get",
        "compute.instanceGroupManagers.list",
        "compute.instanceGroups.get",
        "compute.instanceGroups.list",
        "compute.instances.get",
        "compute.instances.list",
      ]
    }

    monitoring_metrics_scopes_admin = {
      role_id     = "promptqlDdnMonitoringMetricsScopesAdmin"
      title       = "PromptQL DDN - Monitoring Metrics Scopes Admin"
      description = "Least-privilege replacement for roles/monitoring.metricsScopesAdmin, scoped to PromptQL provisioning"
      permissions = [
        "monitoring.metricsScopes.link",
        "resourcemanager.projects.get",
      ]
    }

    certificate_manager_editor = {
      role_id     = "promptqlDdnCertificateManagerEditor"
      title       = "PromptQL DDN - Certificate Manager Editor"
      description = "Least-privilege replacement for roles/certificatemanager.editor, scoped to PromptQL provisioning"
      permissions = [
        "certificatemanager.certmaps.create",
        "certificatemanager.certmaps.get",
        "certificatemanager.certmaps.list",
        "certificatemanager.certmaps.update",
        "certificatemanager.certmaps.delete",
        "certificatemanager.certmapentries.create",
        "certificatemanager.certmapentries.get",
        "certificatemanager.certmapentries.list",
        "certificatemanager.certmapentries.update",
        "certificatemanager.certmapentries.delete",
        "certificatemanager.certs.create",
        "certificatemanager.certs.get",
        "certificatemanager.certs.list",
        "certificatemanager.certs.update",
        "certificatemanager.certs.delete",
        "certificatemanager.dnsauthorizations.create",
        "certificatemanager.dnsauthorizations.get",
        "certificatemanager.dnsauthorizations.list",
        "certificatemanager.dnsauthorizations.update",
        "certificatemanager.dnsauthorizations.delete",
        "certificatemanager.locations.get",
        "certificatemanager.locations.list",
        "certificatemanager.operations.get",
        "certificatemanager.operations.list",
        "certificatemanager.dnsauthorizations.use",
        "certificatemanager.certs.use",
        "certificatemanager.certmaps.use",
      ]
    }

    project_iam_admin = {
      role_id     = "promptqlDdnProjectIamAdmin"
      title       = "PromptQL DDN - Project IAM Admin"
      description = "Least-privilege replacement for roles/resourcemanager.projectIamAdmin, scoped to PromptQL provisioning"
      grants_iam  = true
      grantable_roles = [
        "roles/container.defaultNodeServiceAccount",
        "roles/container.admin",
        "roles/compute.networkViewer",
      ]
      permissions = [
        "resourcemanager.projects.getIamPolicy",
        "resourcemanager.projects.setIamPolicy",
      ]
    }

    service_account_admin = {
      role_id         = "promptqlDdnServiceAccountAdmin"
      title           = "PromptQL DDN - Service Account Admin"
      description     = "Least-privilege replacement for roles/iam.serviceAccountAdmin, scoped to PromptQL provisioning"
      grants_iam      = true
      grantable_roles = ["roles/iam.serviceAccountUser"]
      permissions = [
        "iam.serviceAccounts.create",
        "iam.serviceAccounts.get",
        "iam.serviceAccounts.list",
        "iam.serviceAccounts.update",
        "iam.serviceAccounts.delete",
        "iam.serviceAccounts.getIamPolicy",
        "iam.serviceAccounts.setIamPolicy",
      ]
    }

    cloudsql_admin = {
      role_id     = "promptqlDdnCloudsqlAdmin"
      title       = "PromptQL DDN - Cloud SQL Admin"
      description = "Least-privilege replacement for roles/cloudsql.admin, scoped to PromptQL provisioning"
      permissions = [
        "cloudsql.instances.create",
        "cloudsql.instances.get",
        "cloudsql.instances.list",
        "cloudsql.instances.update",
        "cloudsql.instances.delete",
        "cloudsql.databases.create",
        "cloudsql.databases.get",
        "cloudsql.databases.list",
        "cloudsql.databases.update",
        "cloudsql.databases.delete",
        "cloudsql.users.create",
        "cloudsql.users.get",
        "cloudsql.users.list",
        "cloudsql.users.update",
        "cloudsql.users.delete",
      ]
    }

    workload_identity_pool_admin = {
      role_id     = "promptqlDdnWorkloadIdentityPoolAdmin"
      title       = "PromptQL DDN - Workload Identity Pool Admin"
      description = "Least-privilege replacement for roles/iam.workloadIdentityPoolAdmin, scoped to PromptQL provisioning"
      permissions = [
        "iam.googleapis.com/workloadIdentityPools.create",
        "iam.googleapis.com/workloadIdentityPools.get",
        "iam.googleapis.com/workloadIdentityPools.list",
        "iam.googleapis.com/workloadIdentityPools.update",
        "iam.googleapis.com/workloadIdentityPools.delete",
        "iam.googleapis.com/workloadIdentityPoolProviders.create",
        "iam.googleapis.com/workloadIdentityPoolProviders.get",
        "iam.googleapis.com/workloadIdentityPoolProviders.list",
        "iam.googleapis.com/workloadIdentityPoolProviders.update",
        "iam.googleapis.com/workloadIdentityPoolProviders.delete",
      ]
    }

    storage_admin = {
      role_id     = "promptqlDdnStorageAdmin"
      title       = "PromptQL DDN - Storage Admin"
      description = "Least-privilege replacement for roles/storage.admin, scoped to PromptQL provisioning"
      grants_iam  = true
      grantable_roles = [
        "roles/storage.objectAdmin",
        "roles/storage.objectViewer",
        "roles/storage.legacyBucketReader",
      ]
      permissions = [
        "storage.buckets.create",
        "storage.buckets.get",
        "storage.buckets.list",
        "storage.buckets.update",
        "storage.buckets.delete",
        "storage.buckets.getIamPolicy",
        "storage.buckets.setIamPolicy",
        "storage.objects.list",
        "storage.objects.delete",
      ]
    }

    cloudkms_admin = {
      role_id     = "promptqlDdnCloudkmsAdmin"
      title       = "PromptQL DDN - Cloud KMS Admin"
      description = "Least-privilege replacement for roles/cloudkms.admin, scoped to PromptQL provisioning"
      grants_iam  = true
      grantable_roles = [
        "roles/cloudkms.cryptoKeyDecrypter",
        "roles/cloudkms.cryptoKeyEncrypterDecrypter",
      ]
      permissions = [
        "cloudkms.keyRings.create",
        "cloudkms.keyRings.get",
        "cloudkms.keyRings.list",
        "cloudkms.cryptoKeys.create",
        "cloudkms.cryptoKeys.get",
        "cloudkms.cryptoKeys.list",
        "cloudkms.cryptoKeys.update",
        "cloudkms.cryptoKeys.getIamPolicy",
        "cloudkms.cryptoKeys.setIamPolicy",
        "cloudkms.cryptoKeyVersions.list",
        "cloudkms.cryptoKeyVersions.destroy",
      ]
    }
  }
}

# 1. Enable required APIs (disable_on_destroy=false so teardown never disables a shared API).
resource "google_project_service" "apis" {
  for_each                   = toset(local.required_apis)
  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

# 2. Create the custom roles.
resource "google_project_iam_custom_role" "roles" {
  for_each    = local.custom_roles
  project     = var.project_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = "GA"

  depends_on = [google_project_service.apis]
}

# 3a. Bind roles that do NOT grant IAM to others.
resource "google_project_iam_member" "bindings" {
  for_each = { for k, v in local.custom_roles : k => v if !try(v.grants_iam, false) }
  project  = var.project_id
  role     = google_project_iam_custom_role.roles[each.key].id
  member   = local.member
}

# 3b. Bind roles that carry a setIamPolicy permission WITH the grant-restriction condition.
resource "google_project_iam_member" "iam_granting_bindings" {
  for_each = { for k, v in local.custom_roles : k => v if try(v.grants_iam, false) }
  project  = var.project_id
  role     = google_project_iam_custom_role.roles[each.key].id
  member   = local.member

  condition {
    title       = "Restrict IAM Granting for ddn-automation"
    description = "Roles ddn-automation may grant via ${each.value.role_id}"
    expression  = "api.getAttribute(\"iam.googleapis.com/modifiedGrantsByRole\", []).hasOnly(${jsonencode(each.value.grantable_roles)})"
  }
}