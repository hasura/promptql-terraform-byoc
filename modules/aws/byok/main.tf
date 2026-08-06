data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  count                   = var.create_key ? 1 : 0
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = false
  policy                  = data.aws_iam_policy_document.key_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "this" {
  count         = var.create_key ? 1 : 0
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this[0].key_id
}

data "aws_kms_key" "existing" {
  count  = var.create_key ? 0 : 1
  key_id = var.existing_key_id
}

locals {
  key_arn = var.create_key ? aws_kms_key.this[0].arn : data.aws_kms_key.existing[0].arn
  key_id  = var.create_key ? aws_kms_key.this[0].key_id : data.aws_kms_key.existing[0].id
}

# ---------------------------------------------------------------------------
# Key policy replicating the three statements from the Enterprise Deployment
# (AWS BYOK) guide:
#   1. EnableIAMUserPermissions      - account-root management access
#   2. AllowHasuraDDNCreateGrant     - grant creation with GrantOperations allowlist
#   3. AllowHasuraDDNDescribeKey     - DescribeKey + ListGrants
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "key_policy" {
  policy_id = "hasura-ddn-cmek-policy"

  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowHasuraDDNCreateGrant"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::824267124885:role/HasuraDataPlaneAutomation"]
    }
    actions   = ["kms:CreateGrant"]
    resources = ["*"]
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "kms:GrantOperations"
      values = [
        "Encrypt",
        "Decrypt",
        "ReEncryptFrom",
        "ReEncryptTo",
        "GenerateDataKey",
        "GenerateDataKeyWithoutPlaintext",
        "DescribeKey",
        "CreateGrant",
        "RetireGrant",
      ]
    }
  }

  statement {
    sid    = "AllowHasuraDDNDescribeKey"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::824267124885:role/HasuraDataPlaneAutomation"]
    }
    actions = [
      "kms:DescribeKey",
      "kms:ListGrants",
    ]
    resources = ["*"]
  }
}