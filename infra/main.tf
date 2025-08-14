# Read-only identity lookup for now (doesn't create resources)
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

output "whoami" {
  value = {
    account_id = data.aws_caller_identity.current.account_id
    user_arn   = data.aws_caller_identity.current.arn
    region     = data.aws_region.current.name
  }
}
