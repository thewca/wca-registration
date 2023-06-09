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
  response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
  cached_methods = ["HEAD", "GET", "OPTIONS"]
  default_ttl = "86400"
  name                          = "cdn"
  stage                         = "prod"
  namespace                     = "wca-registration"
}
