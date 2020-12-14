output "iam_role" {
  description = <<-DOC
  IAM Role used to make read or write requests to the delivery channel and to describe the AWS resources associated with 
  the account.
  DOC
  value       = module.this.enabled ? module.iam_role[0].arn : null
}
