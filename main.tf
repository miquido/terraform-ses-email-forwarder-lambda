data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "s3:GetObject",
    ]

    effect = "Allow"

    resources = ["arn:aws:s3:::${var.mail_s3_bucket}/${var.mail_s3_bucket_prefix}/*"]
  }

  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]

    effect = "Allow"

    resources = ["arn:aws:ses:*:*:identity/*"]
  }
}

module "label" {
  enabled    = true
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.8.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, ["ses", "email", "forwarder"]))
  tags       = var.tags
}

locals {
  function_name       = module.label.id
  lambda_zip_filename = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "default" {
  name               = local.function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = module.label.tags
}

resource "aws_iam_role_policy" "default" {
  name   = local.function_name
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.default.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/function.py"
  output_path = local.lambda_zip_filename
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${local.function_name}"
  tags              = module.label.tags
  retention_in_days = var.log_retention
}

data "aws_region" "current" {}

resource "aws_lambda_function" "default" {
  filename                       = local.lambda_zip_filename
  function_name                  = local.function_name
  description                    = local.function_name
  runtime                        = "python3.9"
  role                           = aws_iam_role.default.arn
  handler                        = "function.lambda_handler"
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  tags                           = module.label.tags
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = {
      SesRegion     = var.ses_region == "" ? data.aws_region.current.name : var.ses_region
      MailS3Bucket  = var.mail_s3_bucket
      MailS3Prefix  = var.mail_s3_bucket_prefix
      MailSender    = var.mail_sender
      MailRecipient = var.mail_recipient
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.default,
    aws_iam_role_policy.default,
  ]
}

resource "aws_lambda_alias" "default" {
  name             = "default"
  description      = "Use latest version as default"
  function_name    = aws_lambda_function.default.function_name
  function_version = "$LATEST"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "default" {
  statement_id   = "allowSesInvoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.default.arn
  principal      = "ses.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
}
