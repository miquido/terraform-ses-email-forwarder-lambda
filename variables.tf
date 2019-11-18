variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = string
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "log_retention" {
  type        = number
  default     = 7
  description = "Specifies the number of days you want to retain log events in the specified log group"
}

variable "ses_region" {
  type        = string
  default     = ""
  description = "Specifies the AWS region of SES to be used for sending emails. When not specified default aws provider region is used."
}

variable "mail_s3_bucket" {
  type        = string
  description = "The ID of the bucket where SES saves raw received email messages"
}

variable "mail_s3_bucket_prefix" {
  type        = string
  description = "Key prefix of the email objects used to store emails by SES (should NOT end with a trailing slash `/`)"
}

variable "mail_sender" {
  type        = string
  description = "Email address used as \"From\" value to send an email"
}

variable "mail_recipient" {
  type        = string
  description = "Email address used as \"To\" value to send an email"
}

variable "reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = "The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. See: https://docs.aws.amazon.com/lambda/latest/dg/scaling.html"
}
