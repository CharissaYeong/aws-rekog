module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0"

  function_name = "${var.project_name}-processor"
  handler       = "lambda_function.lambda_handler" # Matches the filename
  runtime       = "python3.12"

  source_path = "${path.module}/src/lambda_function.py"

  create_current_version_allowed_triggers = false

  attach_policy_statements = true
  policy_statements = {
    rekognition = {
      effect    = "Allow"
      actions   = ["rekognition:DetectLabels", "rekognition:DetectText"]
      resources = ["*"]
    }
    dynamodb = {
      effect    = "Allow"
      actions   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
      resources = [aws_dynamodb_table.image_labels.arn]
    }
    s3_read = {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
    }
  }

  # REMOVED allowed_triggers because s3.tf handles it via the notification module

  environment_variables = {
    DYNAMO_TABLE = aws_dynamodb_table.image_labels.name
  }
}