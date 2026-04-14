resource "aws_dynamodb_table" "image_labels" {
  name         = "${var.project_name}-labels"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ImageID"

  # The 'ImageID' will be the S3 Object Key (filename)
  attribute {
    name = "ImageID"
    type = "S"
  }

  # Best practice: Enable Point-in-time recovery 
  # It shows you care about data durability in a professional setting
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-table"
  }
}