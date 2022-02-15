<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![Miquido][logo]](https://www.miquido.com/)

# terraform-ses-email-forwarder-lambda


Lambda used to forward messages received by SES and S3 to an external mailbox
---
**Terraform Module**


GitLab Repository: https://gitlab.com/miquido/terraform/terraform-ses-email-forwarder-lambda

## Usage


Terraform:

```hcl
module "ses-email-forwarder-lambda" {
  source = "git::ssh://git@gitlab.com:miquido/terraform/terraform-ses-email-forwarder-lambda.git?ref=master"

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
```

### Developer notes

* It is recommended to set `MailSender` environment variable carefully to not create email loop in case of receving bounce message (which will be forwarded again, and again..)
* Highly based on: https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 1.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | git::https://github.com/cloudposse/terraform-terraform-label.git | 0.8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_alias.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_function.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | Specifies the number of days you want to retain log events in the specified log group | `number` | `7` | no |
| <a name="input_mail_recipient"></a> [mail\_recipient](#input\_mail\_recipient) | Email address used as "To" value to send an email | `string` | n/a | yes |
| <a name="input_mail_s3_bucket"></a> [mail\_s3\_bucket](#input\_mail\_s3\_bucket) | The ID of the bucket where SES saves raw received email messages | `string` | n/a | yes |
| <a name="input_mail_s3_bucket_prefix"></a> [mail\_s3\_bucket\_prefix](#input\_mail\_s3\_bucket\_prefix) | Key prefix of the email objects used to store emails by SES (should NOT end with a trailing slash `/`) | `string` | n/a | yes |
| <a name="input_mail_sender"></a> [mail\_sender](#input\_mail\_sender) | Email address used as "From" value to send an email | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'cluster' | `string` | `"app"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. See: https://docs.aws.amazon.com/lambda/latest/dg/scaling.html | `number` | `-1` | no |
| <a name="input_ses_region"></a> [ses\_region](#input\_ses\_region) | Specifies the AWS region of SES to be used for sending emails. When not specified default aws provider region is used. | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The ARN of created AWS Lambda function |
<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Makefile Targets
```text
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint Terraform code

```
<!-- markdownlint-restore -->


## Developing

1. Make changes in terraform files

2. Regenerate documentation

    ```bash
    bash <(git archive --remote=git@gitlab.com:miquido/terraform/terraform-readme-update.git master update.sh | tar -xO)
    ```

3. Run lint

    ```
    make lint
    ```

## Copyright

Copyright © 2017-2022 [Miquido](https://miquido.com)



### Contributors

|  [![Konrad Obal][k911_avatar]][k911_homepage]<br/>[Konrad Obal][k911_homepage] |
|---|

  [k911_homepage]: https://github.com/k911
  [k911_avatar]: https://github.com/k911.png?size=150



  [logo]: https://www.miquido.com/img/logos/logo__miquido.svg
  [website]: https://www.miquido.com/
  [gitlab]: https://gitlab.com/miquido
  [github]: https://github.com/miquido
  [bitbucket]: https://bitbucket.org/miquido

