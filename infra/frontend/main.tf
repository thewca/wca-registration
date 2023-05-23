resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = {
    "Name" = var.bucket_name
  }
}

module "cdn" {
  source = "cloudposse/cloudfront-s3-cdn/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"

  origin_bucket     = aws_s3_bucket.this.id
  s3_access_logging_enabled = false
  logging_enabled = false

  name                          = "cdn"
  stage                         = "prod"
  namespace                     = "wca-registration"
}
