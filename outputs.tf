# 1. The S3 Bucket Name
output "s3_bucket_name" {
  description = "The name of the S3 bucket to upload images to"
  value       = module.s3_bucket.s3_bucket_id
}

# 2. The DynamoDB Table Name
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table storing the labels"
  value       = aws_dynamodb_table.image_labels.name
}

# 3. The Lambda Function ARN
output "lambda_function_arn" {
  description = "The ARN of the Lambda function processing the images"
  value       = module.lambda_function.lambda_function_arn
}
