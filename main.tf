#-----------------------------------------------------------------------------------------------------------------------
# Create the AWS Config IAM Role 
#-----------------------------------------------------------------------------------------------------------------------
module "iam_role" {
  count   = module.this.enabled ? 1 : 0
  source  = "cloudposse/iam-role/aws"
  version = "0.6.1"

  principals = {
    "Service" = ["config.amazonaws.com"]
  }

  name         = "aws-config"
  use_fullname = true

  policy_document_count = 1
  policy_documents      = [data.aws_iam_policy_document.config_s3_policy[0].json]

  policy_description = "AWS Config IAM Policy"
  role_description   = "AWS Config IAM Role"

  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  count = module.this.enabled ? 1 : 0

  role       = module.iam_role[0].name
  policy_arn = data.aws_iam_policy.aws_config_built_in_role.arn
}

data "aws_iam_policy" "aws_config_built_in_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "config_s3_policy" {
  count = module.this.enabled ? 1 : 0

  statement {
    sid       = "AWSConfigBucketDelivery"
    effect    = "Allow"
    resources = [local.account_bucket_path]
    actions   = ["s3:PutObject"]
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

#-----------------------------------------------------------------------------------------------------------------------
# Locals and Data References
#-----------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "this" {}

locals {
  account_bucket_path = format("%s/AWSLogs/%s/Config/*", var.s3_bucket_arn, data.aws_caller_identity.this.account_id)
}
