output "lambda_arn" {
  description = "The ARN of created AWS Lambda function"
  value       = aws_lambda_function.default.arn
}
