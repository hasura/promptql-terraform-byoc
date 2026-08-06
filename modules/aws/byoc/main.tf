data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# ---------------------------------------------------------------------------
# IAM role assumed by PromptQL automation (PulumiDDNCli) with ExternalId.
# Ported verbatim from the CloudFormation bootstrap template in the
# enterprise-deployment-aws guide.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::760537944023:role/PulumiDDNCli"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role" "bootstrap_role" {
  name               = var.role_name
  description        = "Role assumed by PromptQL automation to provision and operate the BYOC data plane"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# ---------------------------------------------------------------------------
# Inline policy granting PromptQL automation the least-privilege permission
# set from the CloudFormation template. The identifiers, trust ARN, and
# Created-By/HasuraCloud resource-tag scoping are operationally fixed.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "byoc_policy" {

  # Read-only description of resources PromptQL observes for the data plane.
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeAddressesAttribute",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServiceConfigurations",
      "eks:DeleteAddon",
      "eks:DescribeAddon",
      "eks:DescribeCluster",
      "eks:DescribeNodegroup",
      "eks:ListClusters",
      "iam:GetRole",
      "iam:GetServiceLinkedRoleDeletionStatus",
      "sqs:GetQueueAttributes",
      "rds:DescribeDBInstances",
      "rds:DescribeOrderableDBInstanceOptions",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "kms:ListAliases",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerAttributes",
    ]
    resources = ["*"]
  }

  # Creation of tagged resources. PromptQL tags everything it creates with
  # Created-By=HasuraCloud; creation is only allowed for such requests.
  statement {
    effect = "Allow"
    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateAddress",
      "ec2:AssociateRouteTable",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:CreateSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateVpcEndpoint",
      "ec2:CreateVpcEndpointServiceConfiguration",
      "eks:CreateCluster",
      "eks:CreateNodegroup",
      "globalaccelerator:CreateAccelerator",
      "globalaccelerator:CreateEndpointGroup",
      "globalaccelerator:CreateListener",
      "globalaccelerator:TagResource",
      "sqs:CreateQueue",
      "sqs:TagQueue",
      "acm:RequestCertificate",
      "events:PutRule",
      "events:TagResource",
      "iam:CreateOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "rds:CreateDBSubnetGroup",
      "rds:CreateDBInstance",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateLoadBalancer",
      "lambda:CreateFunction",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Created-By"
      values   = ["HasuraCloud"]
    }
  }

  # Karpenter security-group discovery tags.
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*:${local.account_id}:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/karpenter.sh/discovery"
      values   = ["dataplane"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:DeleteTags"]
    resources = ["arn:aws:ec2:*:${local.account_id}:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/karpenter.sh/discovery"
      values   = ["dataplane"]
    }
  }

  # EKS cluster security-group ingress/egress rules.
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = ["arn:aws:ec2:*:${local.account_id}:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/aws:eks:cluster-name"
      values   = ["dataplane"]
    }
  }

  # EKS access entries.
  statement {
    effect = "Allow"
    actions = [
      "eks:AssociateAccessPolicy",
      "eks:DisassociateAccessPolicy",
    ]
    resources = ["arn:aws:eks:*:${local.account_id}:access-entry/dataplane/*"]
  }

  # IAM management scoped to the operational role/policy/OIDC namespaces.
  statement {
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:CreatePolicyVersion",
      "iam:DeleteInstanceProfile",
      "iam:DeleteOpenIDConnectProvider",
      "iam:DeletePolicy",
      "iam:DeleteRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteServiceLinkedRole",
      "iam:DetachRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:GetInstanceProfile",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListOpenIDConnectProviderTags",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:TagOpenIDConnectProvider",
      "iam:TagPolicy",
      "iam:TagRole",
    ]
    resources = [
      # Roles
      "arn:aws:iam::${local.account_id}:role/KarpenterNodeRole",
      "arn:aws:iam::${local.account_id}:role/KarpenterSandboxNodeRole",
      "arn:aws:iam::${local.account_id}:role/eksClusterRole-*",
      "arn:aws:iam::${local.account_id}:role/lb-controller-*",
      "arn:aws:iam::${local.account_id}:role/autoscaler-controller-*",
      "arn:aws:iam::${local.account_id}:role/global-accelerator-operator-*",
      "arn:aws:iam::${local.account_id}:role/karpenter-controller-*",
      "arn:aws:iam::${local.account_id}:role/HasuraWorkloadAutomationRole-*",
      "arn:aws:iam::${local.account_id}:role/vpc-cni-*",
      "arn:aws:iam::${local.account_id}:role/ebsCsiDriverRole-*",
      "arn:aws:iam::${local.account_id}:role/kms-control-plane-*",
      "arn:aws:iam::${local.account_id}:role/bee-control-plane-*",
      "arn:aws:iam::${local.account_id}:role/bee-data-plane-*",
      "arn:aws:iam::${local.account_id}:role/promptql-artifact-server-*",
      "arn:aws:iam::${local.account_id}:role/dataplane-eks-api-lambda-role-*",
      "arn:aws:iam::${local.account_id}:role/promptql-warehouse-*",
      "arn:aws:iam::${local.account_id}:role/promptql-sandbox-broker-*",
      "arn:aws:iam::${local.account_id}:role/promptql-sandbox-base-publisher-*",
      # Instance profiles
      "arn:aws:iam::${local.account_id}:instance-profile/dataplane_*",
      # Policies
      "arn:aws:iam::${local.account_id}:policy/lb-controller-*",
      "arn:aws:iam::${local.account_id}:policy/autoscaler-controller-*",
      "arn:aws:iam::${local.account_id}:policy/global-accelerator-operator-*",
      "arn:aws:iam::${local.account_id}:policy/karpenter-controller-*",
      "arn:aws:iam::${local.account_id}:policy/dataplane-eks-api-register-targets-*",
      "arn:aws:iam::${local.account_id}:policy/dataplane-eks-api-deregister-targets-*",
      # OIDC providers
      "arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.*",
      "arn:aws:iam::${local.account_id}:oidc-provider/container.googleapis.com/v1/projects/${var.gcp_project_name}/*",
      # Service roles
      "arn:aws:iam::${local.account_id}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
    ]
  }

  # Service-linked roles required by the data plane services.
  statement {
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "spot.amazonaws.com",
        "globalaccelerator.amazonaws.com",
        "eks.amazonaws.com",
        "eks-nodegroup.amazonaws.com",
        "rds.amazonaws.com",
      ]
    }
  }

  # Management of resources tagged Created-By=HasuraCloud.
  statement {
    effect = "Allow"
    actions = [
      "ec2:*",
      "eks:*",
      "globalaccelerator:*",
      "sqs:*",
      "acm:*",
      "events:*",
      "rds:*",
      "s3:*",
      "kms:*",
      "elasticloadbalancing:*",
      "lambda:*",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Created-By"
      values   = ["HasuraCloud"]
    }
  }

  # Object-store buckets used for data plane metadata, warehouse, and sandboxes.
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:CreateBucket",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketVersioning",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:DeleteBucketPolicy",
      "s3:DeleteObjectVersion",
      "s3:DeleteBucket",
    ]
    resources = [
      "arn:aws:s3:::metadata-store-keys-*",
      "arn:aws:s3:::metadata-store-*",
      "arn:aws:s3:::promptql-store-*",
      "arn:aws:s3:::promptql-warehouse-*",
      "arn:aws:s3:::promptql-sandbox-*",
    ]
  }

  # KMS aliases for the data plane CMK.
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:DeleteAlias",
    ]
    resources = ["arn:aws:kms:*:${local.account_id}:alias/bee"]
  }

  # Multi-region VPC endpoint support.
  statement {
    effect    = "Allow"
    actions   = ["vpce:AllowMultiRegion"]
    resources = ["*"]
  }

  # Route53 hosted-zone association for private data plane networking.
  statement {
    effect = "Allow"
    actions = [
      "route53:AssociateVPCWithHostedZone",
      "route53:DisassociateVPCFromHostedZone",
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
}

resource "aws_iam_role_policy" "bootstrap_policy" {
  name   = var.policy_name
  role   = aws_iam_role.bootstrap_role.id
  policy = data.aws_iam_policy_document.byoc_policy.json
}