provider "aws" {
  region = "eu-west-1"
}

resource "aws_ses_receipt_rule_set" "example" {
  rule_set_name = "example"
}

resource "aws_ses_active_receipt_rule_set" "example" {
  rule_set_name = aws_ses_receipt_rule_set.example.rule_set_name
}

resource "aws_ses_receipt_rule" "example" {
  name          = "store-in-s3-forward-lambda"
  rule_set_name = aws_ses_receipt_rule_set.example.rule_set_name

  recipients = [
    "example.com"
  ]
  enabled      = true
  scan_enabled = true

  s3_action {
    bucket_name       = aws_s3_bucket.example.id
    object_key_prefix = "emails/example.com/"
    position          = 1
  }

  lambda_action {
    function_arn    = module.ses-email-forwarder-lambda.lambda_arn
    invocation_type = "Event"
    position        = 2
  }

  depends_on = [aws_s3_bucket_policy.example]
}

resource "aws_s3_bucket" "example" {
  bucket = "example"
  acl    = "private"
}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.example.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "ses-email-forwarder-lambda" {
  source                         = "../../"
  name                           = "main"
  namespace                      = "project"
  stage                          = "example"
  ses_region                     = "eu-west-1"
  mail_sender                    = "noreply-forwarder@example.com"
  mail_recipient                 = "example@example.com"
  mail_s3_bucket                 = aws_s3_bucket.example.id
  mail_s3_bucket_prefix          = "emails/example.com/"
  reserved_concurrent_executions = -1
}
