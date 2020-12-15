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

  use_fullname = true

  policy_description = "AWS Config IAM policy"
  role_description   = "AWS Config IAM role"

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
