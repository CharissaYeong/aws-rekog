# Image storage
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${var.project_name}-"
  
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }
}

module "s3_notification" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "~> 3.0"

  bucket = module.s3_bucket.s3_bucket_id

  lambda_notifications = {
    image_processor = {
      function_arn = module.lambda_function.lambda_function_arn
      function_name = module.lambda_function.lambda_function_name
      events       = ["s3:ObjectCreated:*"]
    }
  }
}