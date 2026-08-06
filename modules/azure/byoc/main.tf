data "azurerm_subscription" "current" {}

# ---------------------------------------------------------------------------
# Custom role "HasuraCloudBYOC": grants PromptQL automation database access on
# flexible PostgreSQL servers. Mirrors the ARM template exactly.
# ---------------------------------------------------------------------------
resource "azurerm_role_definition" "byoc_custom" {
  name        = var.custom_role_name
  scope       = data.azurerm_subscription.current.id
  description = "Role for PromptQL BYOC"

  permissions {
    actions = [
      "Microsoft.DBforPostgreSQL/flexibleServers/*",
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

locals {
  # Azure built-in role definition IDs (fixed across all Azure clouds).
  # The rbacCondition GuidEquals allowlist (five roles, incl. Network
  # Contributor) is exactly the one from the ARM template: the RBAC
  # Administrator assignment may only assign these roles, and only to
  # ServicePrincipal or MSI principals.
  network_contributor_id          = "4d97b98b-1d4f-4787-a291-c67834d212e7"
  managed_identity_contributor_id = "e40ec5ca-96e0-45a2-b4ff-59039f2c2b59"
  managed_identity_operator_id    = "f1a07417-d97a-45cb-824c-7a7467783830"
  aks_contributor_id              = "ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8"
  storage_account_contributor_id  = "17d1049b-9a84-46fb-8f53-869881c3d3ab"
  rbac_administrator_id           = "f58310d9-a9f6-439a-9e8d-f62e7b41a168"

  rbac_condition = "!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'} OR ActionMatches{'Microsoft.Authorization/roleAssignments/delete'}) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {4d97b98b-1d4f-4787-a291-c67834d212e7, acdd72a7-3385-48ef-bd42-f606fba81ae7, b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b, ba92f5b4-2d11-453d-a403-e96b0029c9fe, 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal', 'MSI'})"
}

resource "azurerm_role_assignment" "custom" {
  for_each           = toset(var.resource_group_names)
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_id = azurerm_role_definition.byoc_custom.role_definition_resource_id
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "network_contributor" {
  for_each           = toset(var.resource_group_names)
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.network_contributor_id}"
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "managed_identity_contributor" {
  for_each           = toset(var.resource_group_names)
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.managed_identity_contributor_id}"
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "managed_identity_operator" {
  for_each           = toset(var.resource_group_names)
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.managed_identity_operator_id}"
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "aks_contributor" {
  for_each           = toset(var.resource_group_names)
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.aks_contributor_id}"
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "storage_account_contributor" {
  for_each           = toset(var.resource_group_names)
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.storage_account_contributor_id}"
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "rbac_administrator" {
  for_each           = toset(var.resource_group_names)
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.rbac_administrator_id}"
  principal_id       = var.principal_id
  condition          = local.rbac_condition
  condition_version  = "2.0"
}