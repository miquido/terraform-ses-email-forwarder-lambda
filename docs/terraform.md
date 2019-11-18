## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list(string) | `<list>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| log_retention | Specifies the number of days you want to retain log events in the specified log group | number | `7` | no |
| mail_recipient | Email address used as "To" value to send an email | string | - | yes |
| mail_s3_bucket | The ID of the bucket where SES saves raw received email messages | string | - | yes |
| mail_s3_bucket_prefix | Key prefix of the email objects used to store emails by SES (should NOT end with a trailing slash `/`) | string | - | yes |
| mail_sender | Email address used as "From" value to send an email | string | - | yes |
| name | Solution name, e.g. 'app' or 'cluster' | string | `app` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| reserved_concurrent_executions | The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. See: https://docs.aws.amazon.com/lambda/latest/dg/scaling.html | number | `-1` | no |
| ses_region | Specifies the AWS region of SES to be used for sending emails. When not specified default aws provider region is used. | string | `` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | map(string) | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_arn | The ARN of created AWS Lambda function |

